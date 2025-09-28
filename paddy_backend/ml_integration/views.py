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

import cv2
import numpy as np
from skimage.feature import graycomatrix, graycoprops, hog

def extract_image_features(image_path, IMG_SIZE=(128,128)):
    """
    Optimized feature extractor for paddy disease images.
    Keeps the same name and return type as the original function.
    
    Parameters:
    image_path (str): Path to the image file
    IMG_SIZE (tuple): Size to resize the image to (default: (128, 128))

    Returns:
    np.array: Array of extracted features
    """
    img = cv2.imread(image_path)
    if img is None:
        print(f"Error: Could not read image - {image_path}")
        return None
    
    # Convert to RGB and resize
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_resized = cv2.resize(img, IMG_SIZE, interpolation=cv2.INTER_AREA)

    # HSV summary stats
    hsv = cv2.cvtColor(img_resized, cv2.COLOR_RGB2HSV)
    h_mean, s_mean, v_mean = np.mean(hsv, axis=(0,1))
    h_std, s_std, v_std = np.std(hsv, axis=(0,1))

    # Reduced color histograms (normalized, fewer bins for efficiency)
    hist_bins = 32
    hist_r = cv2.calcHist([img_resized],[0],None,[hist_bins],[0,256]).flatten()
    hist_g = cv2.calcHist([img_resized],[1],None,[hist_bins],[0,256]).flatten()
    hist_b = cv2.calcHist([img_resized],[2],None,[hist_bins],[0,256]).flatten()
    hist = np.concatenate([hist_r, hist_g, hist_b])
    hist = hist / (hist.sum() + 1e-8)

    # GLCM (on quantized grayscale)
    gray = cv2.cvtColor(img_resized, cv2.COLOR_RGB2GRAY)
    glcm_levels = 8
    q = (gray * (glcm_levels / 256.0)).astype('uint8')
    glcm = graycomatrix(q, distances=[1], angles=[0], 
                        levels=glcm_levels, symmetric=True, normed=True)
    contrast = graycoprops(glcm, 'contrast')[0,0]
    correlation = graycoprops(glcm, 'correlation')[0,0]
    energy = graycoprops(glcm, 'energy')[0,0]
    homogeneity = graycoprops(glcm, 'homogeneity')[0,0]
    glcm_feats = np.array([contrast, correlation, energy, homogeneity])

    # HOG features (reduced dimensionality)
    hog_feats = hog(gray, orientations=6, pixels_per_cell=(16,16),
                    cells_per_block=(2,2), block_norm='L2-Hys', feature_vector=True)

    # Combine all features
    combined_features = np.concatenate([
        np.array([h_mean, s_mean, v_mean, h_std, s_std, v_std]),
        glcm_feats,
        hist,
        hog_feats
    ])

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
