import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:paddy_classify_app/resultPage.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paddy Disease Classifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5), // Changed to indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const PaddyDiseaseClassifierPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PaddyDiseaseClassifierPage extends StatefulWidget {
  const PaddyDiseaseClassifierPage({super.key});

  @override
  State<PaddyDiseaseClassifierPage> createState() =>
      _PaddyDiseaseClassifierPageState();
}

class _PaddyDiseaseClassifierPageState
    extends State<PaddyDiseaseClassifierPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _paddyImageFile;
  bool _isLoading = false;
  String _selectedCategory = 'Leaf Blast';

  final List<String> _categories = [
    'Leaf Blast',
    'Brown Spot',
    'Bacterial Blight',
    'Sheath Blight'
  ];

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  Future<void> _takePicture() async {
    bool hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      if (!mounted) return;
      _showSnackBar('Camera permission is required to take pictures');
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (photo != null && mounted) {
        setState(() {
          _paddyImageFile = photo;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('Error picking image: $e');
      _showSnackBar('Error taking picture: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _paddyImageFile = image;
        });
      }
    } catch (e) {
      if (!mounted) return;
      print('Error picking image from gallery: $e');
      _showSnackBar('Error selecting image: $e');
    }
  }

  Future<void> _classifyPaddyDisease() async {
    if (_paddyImageFile == null) {
      _showSnackBar('Please take a paddy leaf image first');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://172.20.10.6:8000/api/predict/'),
      );

      // Add paddy image to the request
      request.files.add(
        await http.MultipartFile.fromPath(
            'disease_image', _paddyImageFile!.path),
      );

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Uncomment when ResultsPage is implemented
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);

        // Navigate to results page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              imageFile: _paddyImageFile!,
              disease: data['disease'],
              confidence: data['confidence'],
              // treatment: data['treatment'],
            ),
          ),
        );
      } else {
        _showSnackBar(
            'Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top App Bar with greeting and profile
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello, Farmer',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ).animate().fadeIn(
                                duration: const Duration(milliseconds: 500)),
                            const SizedBox(height: 4),
                            const Text(
                              'Welcome to Paddy Disease Detector',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ).animate().fadeIn(
                                duration: const Duration(milliseconds: 700)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF3F51B5),
                              size: 28,
                            ),
                          ),
                        )
                            .animate()
                            .scale(duration: const Duration(milliseconds: 500)),
                      ],
                    ),
                  ],
                ),
              ),

              // Main content section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Title for image upload section
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: const Row(
                        children: [
                          Icon(Icons.grass_outlined, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Paddy Disease Scanner',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 800)),

                    // COMPLETELY REDESIGNED IMAGE CAPTURE SECTION
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Top section with either image preview or placeholder
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: double.infinity,
                            height: 220,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              color: _paddyImageFile == null
                                  ? colorScheme.surfaceVariant
                                  : colorScheme.surface,
                            ),
                            child: _paddyImageFile == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer
                                              .withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.panorama,
                                          size: 40,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No image selected",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Use the options below to take a photo",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: colorScheme.onSurfaceVariant
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                        child: Image.file(
                                          File(_paddyImageFile!.path),
                                          width: double.infinity,
                                          height: 220,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // Overlay when loading
                                      if (_isLoading)
                                        Container(
                                          height: 220,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(24),
                                            ),
                                            color:
                                                Colors.black.withOpacity(0.7),
                                          ),
                                          child: Center(
                                            child: Lottie.network(
                                              'https://lottie.host/8b408051-6bb5-436f-b71b-194fa936dcf3/q2q5rJlo65.json',
                                              width: 200,
                                              height: 200,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      // Delete button
                                      if (_paddyImageFile != null &&
                                          !_isLoading)
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _paddyImageFile = null;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),

                          // Divider between image and controls
                          Divider(
                              height: 1,
                              color:
                                  colorScheme.outlineVariant.withOpacity(0.5)),

                          // Controls section
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Take a clear photo of the affected leaf',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        colorScheme.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // New layout for capture options - horizontal cards
                                Row(
                                  children: [
                                    // Camera option
                                    Expanded(
                                      child: _buildCaptureOptionCard(
                                        icon: Icons.camera_alt_rounded,
                                        label: 'Camera',
                                        color: colorScheme.primaryContainer,
                                        onIconColor:
                                            colorScheme.onPrimaryContainer,
                                        onTap: _isLoading ? null : _takePicture,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Gallery option
                                    Expanded(
                                      child: _buildCaptureOptionCard(
                                        icon: Icons.photo_library_rounded,
                                        label: 'Gallery',
                                        color: colorScheme.secondaryContainer,
                                        onIconColor:
                                            colorScheme.onSecondaryContainer,
                                        onTap: _isLoading
                                            ? null
                                            : _selectFromGallery,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Identify button
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: _isLoading
                                        ? null
                                        : (_paddyImageFile == null
                                            ? null
                                            : _classifyPaddyDisease),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      backgroundColor: _paddyImageFile == null
                                          ? colorScheme.primary.withOpacity(0.4)
                                          : colorScheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      disabledBackgroundColor:
                                          colorScheme.primary.withOpacity(0.4),
                                    ),
                                    child: _isLoading
                                        ? const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Analyzing...',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.search),
                                              const SizedBox(width: 8),
                                              Text(
                                                _paddyImageFile == null
                                                    ? 'SELECT AN IMAGE FIRST'
                                                    : 'IDENTIFY DISEASE',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 1000))
                        .slideY(
                            begin: 0.2,
                            end: 0,
                            duration: const Duration(milliseconds: 800)),

                    const SizedBox(height: 32),

                    // Detection Tips section - New addition
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: const Row(
                        children: [
                          Icon(Icons.tips_and_updates_outlined, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Detection Tips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 1100)),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildTipItem(
                            icon: Icons.light_mode_outlined,
                            tip: 'Take photos in good lighting conditions',
                          ),
                          const SizedBox(height: 12),
                          _buildTipItem(
                            icon: Icons.crop_free_outlined,
                            tip: 'Focus clearly on the affected area',
                          ),
                          const SizedBox(height: 12),
                          _buildTipItem(
                            icon: Icons.back_hand_outlined,
                            tip: 'Hold the camera steady for best results',
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 1200)),

                    const SizedBox(height: 32),

                    // History section with elegant title
                    Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.history_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Detection history',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Text('See all'),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 1300)),

                    const SizedBox(height: 16),

                    // History cards with modern design
                    SizedBox(
                      height: 210,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildHistoryCard(
                            'Leaf Blast',
                            '3 days ago',
                            'assets/leaf_blast.jpg',
                            colorScheme,
                          ).animate().fadeIn(
                                duration: const Duration(milliseconds: 1400),
                                delay: const Duration(milliseconds: 100),
                              ),
                          _buildHistoryCard(
                            'Brown Spot',
                            '1 week ago',
                            'assets/brown_spot.jpg',
                            colorScheme,
                          ).animate().fadeIn(
                                duration: const Duration(milliseconds: 1400),
                                delay: const Duration(milliseconds: 200),
                              ),
                          _buildHistoryCard(
                            'Bacterial Blight',
                            '2 weeks ago',
                            'assets/bacterial_blight.jpg',
                            colorScheme,
                          ).animate().fadeIn(
                                duration: const Duration(milliseconds: 1400),
                                delay: const Duration(milliseconds: 300),
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            backgroundColor: Colors.white,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: 'History',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline_rounded),
                label: 'Info',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color onIconColor,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: onIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem({required IconData icon, required String tip}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(String diseaseName, String timeAgo, String imagePath,
      ColorScheme colorScheme) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section with colored overlay
          Stack(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                // Replace with actual image
                child: Center(
                  child: Icon(
                    Icons.eco_rounded,
                    color: colorScheme.primary.withOpacity(0.7),
                    size: 40,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          // Info section with modern typography
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    diseaseName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Detected $timeAgo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
