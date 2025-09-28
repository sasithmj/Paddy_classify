import 'package:flutter/material.dart';
import 'package:paddy_classify_app/paddy_Treatments_Suggestions.dart';
import 'package:paddy_classify_app/service/PaddyApiService.dart';

class UserInputPage extends StatefulWidget {
  @override
  _UserInputPageState createState() => _UserInputPageState();
}

class _UserInputPageState extends State<UserInputPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const List<Map<String, dynamic>> diseases = [
    {
      'name': 'Rice Blast',
      'description': 'Fungal disease causing lesions on leaves and panicles',
      'icon': Icons.coronavirus,
      'severity': 'High',
      'color': Colors.red,
    },
    {
      'name': 'False Smut',
      'description': 'Produces orange-black smut balls replacing grains',
      'icon': Icons.bubble_chart,
      'severity': 'Medium',
      'color': Colors.orange,
    },
    {
      'name': 'Sheath Blight',
      'description': 'Affects leaf sheaths and stems',
      'icon': Icons.grass,
      'severity': 'Medium',
      'color': Colors.amber,
    },
    {
      'name': 'Bacterial Leaf Blight',
      'description': 'Bacterial infection causing leaf wilting',
      'icon': Icons.local_florist,
      'severity': 'High',
      'color': Colors.deepOrange,
    },
    {
      'name': 'Sheath Rot',
      'description': 'Rotting of leaf sheaths and panicles',
      'icon': Icons.opacity,
      'severity': 'Medium',
      'color': Colors.brown,
    },
  ];

  static const List<String> locations = [
    'Ampara',
    'Anuradhapura',
    'Badulla',
    'Batticaloa',
    'Colombo',
    'Galle',
    'Gampaha',
    'Hambantota',
    'Jaffna',
    'Kalutara',
    'Kandy',
    'Kilinochchi',
    'Kurunegala',
    'Mannar',
    'Matale',
    'Monaragala',
    'Mullaitivu',
    'Polonnaruwa',
    'Puttalam',
    'Ratnapura',
    'Trincomalee',
    'Vavuniya',
  ];

  static const List<Map<String, dynamic>> controlMethods = [
    {
      'name': 'Biological',
      'description': 'Natural predators and beneficial microorganisms',
      'icon': Icons.eco,
      'color': Colors.green,
    },
    {
      'name': 'Chemical',
      'description': 'Fungicides and pesticides',
      'icon': Icons.science,
      'color': Colors.blue,
    },
    {
      'name': 'Traditional',
      'description': 'Cultural practices and organic methods',
      'icon': Icons.agriculture,
      'color': Colors.brown,
    },
  ];

  String? selectedDisease;
  String? selectedLocation;
  String? selectedControlMethod;
  int? budget;

  bool isLoading = false;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> submitData() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    try {
      final submitResult = await PaddyApiService.submitUserInput(
        disease: selectedDisease!,
        budget: budget!,
        location: selectedLocation!,
        controlMethod: selectedControlMethod!,
      );

      final instance = submitResult['instance'];

      // Show progress indication
      _showAnalysisProgress();

      // Fetch GET request data
      final generalTreatments =
          await PaddyApiService.getUserGeneralTreatments(instance);
      final diseaseAgent =
          await PaddyApiService.getDiseaseAgent(selectedDisease!);
      final diseaseDetails =
          await PaddyApiService.getUserDiseaseDetails(instance);
      final diseaseEnvironment =
          await PaddyApiService.getDiseaseEnvironment(selectedDisease!);
      final suitableTreatments =
          await PaddyApiService.getSuitableTreatments(instance);
      final generalGuidelines = await PaddyApiService.getGeneralGuidelines();

      Navigator.pop(context); // Close progress dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TreatmentPage(
            userInput: {
              "disease": selectedDisease!,
              "budget": budget!,
              "location": selectedLocation!,
              "controlMethod": selectedControlMethod!,
            },
            instance: instance,
            generalTreatments: generalTreatments,
            diseaseAgent: diseaseAgent,
            diseaseDetails: diseaseDetails,
            diseaseEnvironment: diseaseEnvironment,
            suitableTreatments: suitableTreatments,
            generalGuidelines: generalGuidelines,
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Close any open dialogs
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showAnalysisProgress() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                ),
                SizedBox(height: 16),
                Text(
                  'Analyzing...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Please wait while we process your request',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Paddy Disease Analysis'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                SizedBox(height: 24),
                _buildProgressIndicator(),
                SizedBox(height: 24),
                _buildDiseaseSelectionCard(),
                SizedBox(height: 16),
                _buildLocationCard(),
                SizedBox(height: 16),
                _buildBudgetCard(),
                SizedBox(height: 16),
                _buildControlMethodCard(),
                SizedBox(height: 32),
                _buildSubmitButton(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
                Icon(Icons.agriculture, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Paddy Care',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'AI-powered disease diagnosis & treatment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Help us understand your paddy\'s condition by providing the following information.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.95),
                fontSize: 16,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int totalSteps = 4;
    int completedSteps = 0;
    if (selectedDisease != null) completedSteps++;
    if (selectedLocation != null) completedSteps++;
    if (budget != null) completedSteps++;
    if (selectedControlMethod != null) completedSteps++;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '$completedSteps/$totalSteps',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: completedSteps / totalSteps,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseSelectionCard() {
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
                Icon(Icons.coronavirus, color: Colors.red[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Disease Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'What disease symptoms are you observing?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ...diseases.map((disease) => _buildDiseaseOption(disease)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseOption(Map<String, dynamic> disease) {
    bool isSelected = selectedDisease == disease['name'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => selectedDisease = disease['name']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? disease['color'] : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color:
                isSelected ? disease['color'].withOpacity(0.1) : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                disease['icon'],
                color: disease['color'],
                size: 28,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      disease['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: disease['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  disease['severity'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: disease['color'],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
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
                Icon(Icons.location_on, color: Colors.blue[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select your district',
                prefixIcon: Icon(Icons.map, color: Colors.blue[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue[25],
              ),
              value: selectedLocation,
              items: locations
                  .map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc),
                      ))
                  .toList(),
              validator: (value) =>
                  value == null ? 'Please select your location' : null,
              onChanged: (value) => setState(() => selectedLocation = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard() {
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
                Icon(Icons.account_balance_wallet,
                    color: Colors.green[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Budget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Treatment budget (LKR)',
                prefixIcon:
                    Icon(Icons.currency_exchange, color: Colors.green[600]),
                prefixText: 'Rs. ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.green[25],
                helperText: 'Enter your available budget for treatment',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your budget';
                }
                if (int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  budget = int.tryParse(value);
                });
              },
              onSaved: (value) => budget = int.tryParse(value!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlMethodCard() {
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
                Icon(Icons.healing, color: Colors.purple[600], size: 24),
                SizedBox(width: 12),
                Text(
                  'Preferred Treatment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Choose your preferred approach for treatment:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ...controlMethods
                .map((method) => _buildControlMethodOption(method))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlMethodOption(Map<String, dynamic> method) {
    bool isSelected = selectedControlMethod == method['name'];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => selectedControlMethod = method['name']),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? method['color'] : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected ? method['color'].withOpacity(0.1) : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                method['icon'],
                color: method['color'],
                size: 28,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      method['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: method['color'],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    bool isFormComplete = selectedDisease != null &&
        selectedLocation != null &&
        budget != null &&
        selectedControlMethod != null;

    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormComplete && !isLoading ? submitData : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          elevation: isFormComplete ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Analyzing...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Get Treatment Recommendations',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
