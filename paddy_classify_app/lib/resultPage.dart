import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultsPage extends StatelessWidget {
  final XFile imageFile;
  final String disease;
  final num confidence;
  // final String treatment;

  const ResultsPage({
    super.key,
    required this.imageFile,
    required this.disease,
    required this.confidence,
    // required this.treatment,
  });

  @override
  Widget build(BuildContext context) {
    // Show snackbar when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disease Analysis Completed'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Results'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Display
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imageFile.path),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(confidence),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getSeverityIcon(confidence),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getSeverityLabel(confidence),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Disease Result
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Identified Disease',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        disease,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Confidence Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 8,
                            width: MediaQuery.of(context).size.width *
                                0.8 * // Account for padding
                                (confidence / 100),
                            decoration: BoxDecoration(
                              color: _getConfidenceColor(confidence),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${confidence.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(confidence),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Treatment Recommendations
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            color: Colors.green,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Treatment Recommendations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Text(
                      //   treatment,
                      //   style: const TextStyle(
                      //     fontSize: 15,
                      //     height: 1.5,
                      //   ),
                      // ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          _launchUrl(
                              'https://www.google.com/search?q=how+to+treat+$disease+in+paddy');
                        },
                        icon: const Icon(Icons.search),
                        label: const Text('Learn more about this disease'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Prevention Tips
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Prevention Tips',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildPreventionTip(
                        '1. Use disease-resistant paddy varieties when available',
                        context,
                      ),
                      _buildPreventionTip(
                        '2. Practice proper field sanitation by removing infected plants',
                        context,
                      ),
                      _buildPreventionTip(
                        '3. Maintain optimal water management to reduce stress on plants',
                        context,
                      ),
                      _buildPreventionTip(
                        '4. Apply balanced fertilization based on soil testing',
                        context,
                      ),
                      _buildPreventionTip(
                        '5. Monitor fields regularly for early detection of diseases',
                        context,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Another'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Share functionality
                        // Share.share(
                        //     'I identified $disease in my paddy field with ${confidence.toStringAsFixed(1)}% confidence using the Paddy Disease Classifier app. Recommended treatment: ${treatment.split('.').first}.');
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Share Results'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create prevention tip items
  Widget _buildPreventionTip(String tip, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get color based on confidence level
  Color _getConfidenceColor(num confidence) {
    if (confidence >= 90) {
      return Colors.green;
    } else if (confidence >= 70) {
      return Colors.lime;
    } else if (confidence >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Helper method to get severity color
  Color _getSeverityColor(num confidence) {
    if (confidence >= 90) {
      return Colors.red[700]!;
    } else if (confidence >= 70) {
      return Colors.orange;
    } else if (confidence >= 50) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  // Helper method to get severity label
  String _getSeverityLabel(num confidence) {
    if (confidence >= 90) {
      return 'Severe';
    } else if (confidence >= 70) {
      return 'Moderate';
    } else if (confidence >= 50) {
      return 'Mild';
    } else {
      return 'Low Risk';
    }
  }

  // Helper method to get severity icon
  IconData _getSeverityIcon(num confidence) {
    if (confidence >= 70) {
      return Icons.warning;
    } else {
      return Icons.info_outline;
    }
  }

  // Helper method to launch URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}
