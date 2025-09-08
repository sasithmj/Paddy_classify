from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
import os
import cv2
import numpy as np
import joblib
from skimage.feature import graycomatrix, graycoprops, hog
from django.conf import settings

# Load trained model
rf_model = joblib.load("ml_models/best_paddy_rf_model.pkl")

DISEASE_NAMES = {
    0: "Sheath Rot",
    1: "Sheath Blight",
    2: "BLB",
    3: "FalseMut",
    4: "Rice Blast",
}

def extract_image_features(image_path, IMG_SIZE=(256, 256)):
    """
    Extract comprehensive image features combining texture, color, shape, histogram, and HOG features.
    This function matches exactly what was used during model training.
    
    Parameters:
    image_path (str): Path to the image file
    IMG_SIZE (tuple): Size to resize the image to (default: (256, 256))
    
    Returns:
    np.array: Array of extracted features
    """
    # Load image
    image = cv2.imread(image_path)
    if image is None:
        print(f"Error: Image not found - {image_path}")
        return None

    # Resize for consistency
    resized_image = cv2.resize(image, IMG_SIZE)

    # Convert BGR to RGB
    rgb_image = cv2.cvtColor(resized_image, cv2.COLOR_BGR2RGB)

    # Convert to grayscale
    gray_image = cv2.cvtColor(resized_image, cv2.COLOR_BGR2GRAY)

    # Apply Adaptive Histogram Equalization (CLAHE)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced_image = clahe.apply(gray_image)

    # Apply Gaussian Blur
    blurred_image = cv2.GaussianBlur(enhanced_image, (5, 5), 0)

    # Texture Features (GLCM)
    glcm = graycomatrix(blurred_image, distances=[1], angles=[0], levels=256, symmetric=True, normed=True)
    contrast = graycoprops(glcm, 'contrast')[0, 0]
    correlation = graycoprops(glcm, 'correlation')[0, 0]
    energy = graycoprops(glcm, 'energy')[0, 0]
    homogeneity = graycoprops(glcm, 'homogeneity')[0, 0]

    # Color Features (HSV)
    hsv_image = cv2.cvtColor(resized_image, cv2.COLOR_BGR2HSV)
    h_mean, s_mean, v_mean = np.mean(hsv_image, axis=(0, 1))
    h_std, s_std, v_std = np.std(hsv_image, axis=(0, 1))

    # Shape Features
    edges = cv2.Canny(blurred_image, 100, 200)
    contours, _ = cv2.findContours(edges, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    num_contours = len(contours)
    avg_contour_area = np.mean([cv2.contourArea(c) for c in contours]) if contours else 0
    avg_contour_perimeter = np.mean([cv2.arcLength(c, True) for c in contours]) if contours else 0

    # Elongation Ratio
    if contours:
        largest_contour = max(contours, key=cv2.contourArea)
        x, y, w, h = cv2.boundingRect(largest_contour)
        elongation_ratio = h / w if w != 0 else 0
        major_axis_length = max(w, h)
    else:
        elongation_ratio = 0
        major_axis_length = 0

    # Histogram Features (Color Distribution)
    hist_r = cv2.calcHist([rgb_image], [0], None, [256], [0, 256])
    hist_g = cv2.calcHist([rgb_image], [1], None, [256], [0, 256])
    hist_b = cv2.calcHist([rgb_image], [2], None, [256], [0, 256])

    # Normalize histogram features
    hist_r = cv2.normalize(hist_r, hist_r).flatten()
    hist_g = cv2.normalize(hist_g, hist_g).flatten()
    hist_b = cv2.normalize(hist_b, hist_b).flatten()

    # Combine histogram features
    hist_features = np.concatenate((hist_r, hist_g, hist_b))

    # HOG Feature Extraction
    hog_features = hog(gray_image, orientations=9, pixels_per_cell=(8, 8),
                      cells_per_block=(2, 2), block_norm='L2-Hys', feature_vector=True)

    # Basic features
    basic_features = np.array([
        contrast, correlation, energy, homogeneity,
        h_mean, s_mean, v_mean,
        h_std, s_std, v_std,
        num_contours, avg_contour_area, avg_contour_perimeter,
        elongation_ratio, major_axis_length
    ])

    # Combine all features
    combined_features = np.concatenate((basic_features, hist_features, hog_features))
    
    return combined_features


@csrf_exempt
def classify_paddy_disease(request):
    if request.method == 'POST':
        if 'disease_image' not in request.FILES:
            return JsonResponse({'error': 'Disease image is required'}, status=400)

        try:
            # Save uploaded image
            image_file = request.FILES['disease_image']
            image_path = default_storage.save('tmp/' + image_file.name, ContentFile(image_file.read()))
            image_full_path = os.path.join(settings.MEDIA_ROOT, image_path)

            print(f"Image saved at: {image_full_path}")  # Debugging line

            # Extract features
            features = extract_image_features(image_full_path)
            if features is None:
                print("Feature extraction failed")  # Debugging line
                return JsonResponse({'error': 'Feature extraction failed'}, status=500)

            features = features.flatten()

            # Ensure feature vector matches model expectations
            expected_feature_size = 35379
            if features.shape[0] < expected_feature_size:
                features = np.pad(features, (0, expected_feature_size - features.shape[0]), mode="constant")

            # Convert to 2D array (1 sample, N features)
            features = features.reshape(1, -1)

            # Predict using the trained model
            predicted_class = rf_model.predict(features)[0]
            class_probabilities = rf_model.predict_proba(features)[0]  # Now features are in correct shape

            # Get the probability of the predicted class
            predicted_class_index = np.argmax(class_probabilities)
            predicted_class_probability = class_probabilities[predicted_class_index]
            print(class_probabilities)


            disease_name = DISEASE_NAMES.get(predicted_class, "Unknown Disease")

            return JsonResponse({'disease': disease_name, 'confidence': predicted_class_probability*100})  # Example confidence value

        except Exception as e:
            import traceback
            print("ERROR:", traceback.format_exc())  # Prints full error stack trace
            return JsonResponse({'error': str(e)}, status=500)
    else:
        return JsonResponse({'error': 'Invalid request method'}, status=400)
