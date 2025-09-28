import 'package:flutter/material.dart';
import 'package:paddy_classify_app/service/PaddyApiService.dart';

class TreatmentPage extends StatefulWidget {
  final Map<String, dynamic> userInput;
  final String instance;
  final List<dynamic> generalTreatments;
  final List<dynamic> diseaseAgent;
  final List<dynamic> diseaseDetails;
  final List<dynamic> diseaseEnvironment;
  final List<dynamic> suitableTreatments;
  final List<dynamic> generalGuidelines;

  TreatmentPage({
    required this.userInput,
    required this.instance,
    required this.generalTreatments,
    required this.diseaseAgent,
    required this.diseaseDetails,
    required this.diseaseEnvironment,
    required this.suitableTreatments,
    required this.generalGuidelines,
  });

  @override
  _TreatmentPageState createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to extract value from API response format
  String extractValue(dynamic data, String key) {
    if (data is Map<String, dynamic> && data[key] != null) {
      if (data[key] is Map<String, dynamic> && data[key]['value'] != null) {
        return data[key]['value'].toString();
      }
      return data[key].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Treatment Analysis'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.green[100],
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.healing), text: 'Treatment'),
            Tab(icon: Icon(Icons.bug_report), text: 'Disease Info'),
            Tab(icon: Icon(Icons.info_outline), text: 'Details'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTreatmentTab(),
          _buildDiseaseInfoTab(),
          _buildDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildTreatmentTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickSummaryCard(),
          SizedBox(height: 16),
          _buildGeneralTreatmentsCard(),
          SizedBox(height: 16),
          _buildGeneralGuidelinesCard(),
        ],
      ),
    );
  }

  Widget _buildDiseaseInfoTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDiseaseDetailsCard(),
          SizedBox(height: 16),
          _buildDiseaseAgentCard(),
          SizedBox(height: 16),
          _buildEnvironmentCard(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildUserInputCard(),
          SizedBox(height: 16),
          _buildInstanceCard(),
        ],
      ),
    );
  }

  Widget _buildQuickSummaryCard() {
    String diseaseName = '';
    if (widget.diseaseDetails.isNotEmpty) {
      diseaseName = extractValue(widget.diseaseDetails[0], 'diseaseName');
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green[400]!, Colors.green[600]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.white, size: 28),
                SizedBox(width: 12),
                Text(
                  'Diagnosis Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (diseaseName.isNotEmpty)
                    Text(
                      'Detected: $diseaseName',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (diseaseName.isNotEmpty) SizedBox(height: 8),
                  Text(
                    widget.suitableTreatments.isNotEmpty
                        ? '✓ Specific treatments available'
                        : 'General treatments recommended',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuitableTreatmentsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[300]!, width: 2),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.medication,
                        color: Colors.red[600], size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Recommended Treatments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'PRIORITY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ...widget.suitableTreatments
                  .map((treatment) => _buildTreatmentDetailCard(treatment))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentDetailCard(Map<String, dynamic> treatment) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Treatment Name/Products
          if (extractValue(treatment, 'controlMethodName').isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_pharmacy, color: Colors.blue[600], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      extractValue(treatment, 'controlMethodName'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
          ],

          // Active Ingredient
          if (extractValue(treatment, 'activeIngredient').isNotEmpty)
            _buildInfoRow(
              Icons.science,
              'Active Ingredient',
              extractValue(treatment, 'activeIngredient'),
              Colors.purple[600]!,
            ),

          // Description
          if (extractValue(treatment, 'methodDescription').isNotEmpty)
            _buildInfoRow(
              Icons.description,
              'How it Works',
              extractValue(treatment, 'methodDescription'),
              Colors.green[600]!,
            ),

          // Instructions
          if (extractValue(treatment, 'instructionsVal').isNotEmpty)
            _buildInfoRow(
              Icons.format_list_numbered,
              'Application Instructions',
              extractValue(treatment, 'instructionsVal'),
              Colors.orange[600]!,
            ),

          // Application Frequency
          if (extractValue(treatment, 'applicationFrequencyVal').isNotEmpty)
            _buildInfoRow(
              Icons.schedule,
              'Application Schedule',
              extractValue(treatment, 'applicationFrequencyVal'),
              Colors.indigo[600]!,
            ),

          // Conditions
          if (extractValue(treatment, 'conditionVal').isNotEmpty)
            _buildInfoRow(
              Icons.wb_sunny,
              'Optimal Conditions',
              extractValue(treatment, 'conditionVal'),
              Colors.amber[600]!,
            ),

          // Effectiveness
          if (extractValue(treatment, 'effectiveness').isNotEmpty)
            _buildInfoRow(
              Icons.trending_up,
              'Effectiveness',
              extractValue(treatment, 'effectiveness'),
              Colors.green[700]!,
            ),

          // Safety Measures
          if (extractValue(treatment, 'safetyMeasuresVal').isNotEmpty)
            _buildInfoRow(
              Icons.security,
              'Safety Measures',
              extractValue(treatment, 'safetyMeasuresVal'),
              Colors.red[600]!,
            ),

          // Environment Impact
          if (extractValue(treatment, 'environmentImpactVal').isNotEmpty)
            _buildInfoRow(
              Icons.eco,
              'Environmental Impact',
              extractValue(treatment, 'environmentImpactVal'),
              Colors.teal[600]!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    if (value.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color.fromARGB(255, 39, 39, 39),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value.replaceAll('\\n', '\n').replaceAll('➤', '•'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTreatmentsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.healing, color: Colors.blue[600], size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'General Treatments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (widget.generalTreatments.isEmpty)
              _buildEmptyState()
            else
              ...widget.generalTreatments
                  .map((treatment) => _buildTreatmentDetailCard(treatment))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralGuidelinesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.rule, color: Colors.orange[600], size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'General Guidelines',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (widget.generalGuidelines.isEmpty)
              _buildEmptyState()
            else
              ...widget.generalGuidelines
                  .map((guideline) => _buildGuidelineItem(guideline))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineItem(Map<String, dynamic> guideline) {
    String title = extractValue(guideline, 'guideline');
    String description = extractValue(guideline, 'gDescription');

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[25],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: Colors.orange[600], size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) SizedBox(height: 8),
          ],
          if (description.isNotEmpty)
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiseaseDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description,
                      color: Colors.purple[600], size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  'Disease Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (widget.diseaseDetails.isEmpty)
              _buildEmptyState()
            else
              ...widget.diseaseDetails
                  .map((detail) => _buildDiseaseDetailItem(detail))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseDetailItem(Map<String, dynamic> detail) {
    String diseaseName = extractValue(detail, 'diseaseName');
    String symptoms = extractValue(detail, 'overallSymptoms');

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple[25],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (diseaseName.isNotEmpty) ...[
            Text(
              diseaseName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.purple[800],
              ),
            ),
            if (symptoms.isNotEmpty) SizedBox(height: 8),
          ],
          if (symptoms.isNotEmpty)
            Text(
              symptoms.replaceAll('\\n', '\n'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiseaseAgentCard() {
    return _buildSimpleInfoCard(
      title: 'Disease Agent',
      icon: Icons.bug_report,
      iconColor: Colors.red[800]!,
      data: widget.diseaseAgent,
      fields: ['scientificName', 'type'],
      labels: ['Scientific Name', 'Type'],
    );
  }

  Widget _buildEnvironmentCard() {
    return _buildSimpleInfoCard(
      title: 'Environmental Conditions',
      icon: Icons.eco,
      iconColor: Colors.green[700]!,
      data: widget.diseaseEnvironment,
      fields: ['temperature', 'humidity', 'soilMoisture', 'rainfallPattern'],
      labels: ['Temperature', 'Humidity', 'Soil Moisture', 'Rainfall Pattern'],
    );
  }

  Widget _buildSimpleInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<dynamic> data,
    required List<String> fields,
    required List<String> labels,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (data.isEmpty)
              _buildEmptyState()
            else
              ...data
                  .take(1)
                  .map((item) => // Show only first item to avoid duplicates
                      _buildSimpleInfoItem(item, fields, labels))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleInfoItem(
      Map<String, dynamic> item, List<String> fields, List<String> labels) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: List.generate(fields.length, (index) {
          String value = extractValue(item, fields[index]);
          if (value.isEmpty) return SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(bottom: index < fields.length - 1 ? 8 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${labels[index]}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: value,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildUserInputCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.input, color: Colors.indigo[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Your Input',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo[25],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Column(
                children: widget.userInput.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_formatKey(entry.key)}: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo[800],
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.teal[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Analysis ID',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[25],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Text(
                widget.instance.isNotEmpty
                    ? widget.instance
                    : 'No instance ID available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal[800],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'No data available',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }
}
