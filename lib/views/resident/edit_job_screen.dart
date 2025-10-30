import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EditJobScreen extends StatefulWidget {
  final Map<String, dynamic> jobData;
  const EditJobScreen({Key? key, required this.jobData}) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workersRequiredController =
      TextEditingController();
  final TextEditingController _safetyInstructionsController =
      TextEditingController();
  final TextEditingController _payAmountController = TextEditingController();
  final TextEditingController _advanceAmountController =
      TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Form values
  String _jobType = 'full_day';
  List<String> _skillsRequired = [];
  bool _toolsProvided = false;
  List<String> _documentsRequired = [];
  String _payType = 'per_day';
  bool _advancePayment = false;

  final Map<String, String> _shiftOptions = const {
    'morning': 'Morning (09:00Am-12:00Pm)',
    'afternoon': 'Afternoon (12:00Pm-05:00Pm)',
    'evening': 'Evening (05:00Pm-09:00Pm)',
  };
  String? _selectedShift;

  final Map<String, String> _jobTypeOptions = const {
    'full_day': 'Full Day',
    'part_time': 'Part Time',
    'hourly': 'Hourly',
  };

  final Map<String, String> _payTypeOptions = const {
    'per_day': 'Per Day',
    'per_hour': 'Per Hour',
    'fixed': 'Fixed',
  };

  final List<String> _availableSkills = const [
    'Painter',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Helper',
    'Mason',
  ];

  final List<String> _availableDocuments = const [
    'ID',
    'Address Proof',
    'Police Verification',
  ];

  @override
  void initState() {
    super.initState();
    final job = widget.jobData;

    // Text fields
    _jobTitleController.text = job['job_title']?.toString() ?? '';
    _locationController.text = job['location']?.toString() ?? '';
    _addressController.text = job['address']?.toString() ?? '';
    _workersRequiredController.text = job['workers_required']?.toString() ?? '';
    _safetyInstructionsController.text =
        job['safety_instructions']?.toString() ?? '';
    _payAmountController.text = job['pay_amount']?.toString() ?? '';
    _advanceAmountController.text = job['advance_amount']?.toString() ?? '';
    _startDateController.text = _parseDate(job['start_date']);
    _endDateController.text = _parseDate(job['end_date']);

    // Job type
    if (job['job_type'] != null &&
        _jobTypeOptions.containsKey(job['job_type'])) {
      _jobType = job['job_type'];
    }

    // Skills required
    if (job['skills_required'] is List) {
      _skillsRequired = List<String>.from(job['skills_required']);
    }

    // Tools provided
    _toolsProvided = job['tools_provided'] == true;

    // Documents required
    if (job['documents_required'] is List) {
      _documentsRequired = List<String>.from(job['documents_required']);
    }

    // Pay type
    if (job['pay_type'] != null &&
        _payTypeOptions.containsKey(job['pay_type'])) {
      _payType = job['pay_type'];
    }

    // Advance payment
    _advancePayment = job['advance_payment'] == true;

    // Shift prefill
    _selectedShift =
        job['shift'] != null && _shiftOptions.containsKey(job['shift'])
            ? job['shift']
            : 'morning';
  }

  String _parseDate(dynamic value) {
    if (value == null) return '';
    try {
      return DateTime.parse(value).toString().split(' ')[0];
    } catch (_) {
      return value.toString();
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _workersRequiredController.dispose();
    _safetyInstructionsController.dispose();
    _payAmountController.dispose();
    _advanceAmountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD4A745), Color(0xFF7BC57B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black54, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.black87, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Edit Job',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form Container
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5E6B3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Job Title
                          _buildLabel('Job Title'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _jobTitleController,
                            hint: 'Enter Job Title',
                          ),
                          const SizedBox(height: 16),

                          // Location (City)
                          _buildLabel('Location'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _locationController,
                            hint: 'Enter City/Location',
                          ),
                          const SizedBox(height: 16),

                          // Address
                          _buildLabel('Address'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _addressController,
                            hint: 'Enter Full Address',
                          ),
                          const SizedBox(height: 16),

                          // Job Type
                          _buildLabel('Job Type'),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _jobType,
                            hint: 'Select Job Type',
                            items: _jobTypeOptions.keys.toList(),
                            itemLabels: _jobTypeOptions,
                            onChanged: (value) {
                              setState(() {
                                _jobType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Workers Required
                          _buildLabel('Workers Required'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _workersRequiredController,
                            hint: 'Enter Number of Workers',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Skills Required
                          _buildLabel('Skills Required'),
                          const SizedBox(height: 8),
                          _buildMultiSelectChips(
                            availableItems: _availableSkills,
                            selectedItems: _skillsRequired,
                            onChanged: (selected) {
                              setState(() {
                                _skillsRequired = selected;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Tools Provided
                          _buildLabel('Tools Provided'),
                          const SizedBox(height: 8),
                          _buildCheckbox('Provide Tools', _toolsProvided, () {
                            setState(() {
                              _toolsProvided = !_toolsProvided;
                            });
                          }),
                          const SizedBox(height: 16),

                          // Documents Required
                          _buildLabel('Documents Required'),
                          const SizedBox(height: 8),
                          _buildMultiSelectChips(
                            availableItems: _availableDocuments,
                            selectedItems: _documentsRequired,
                            onChanged: (selected) {
                              setState(() {
                                _documentsRequired = selected;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Safety Instructions
                          _buildLabel('Safety Instructions'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _safetyInstructionsController,
                            hint: 'Enter Safety Instructions',
                          ),
                          const SizedBox(height: 16),

                          // Start Date
                          _buildLabel('Start Date'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _startDateController,
                            hint: 'yyyy-mm-dd',
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                _startDateController.text =
                                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // End Date
                          _buildLabel('End Date'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _endDateController,
                            hint: 'yyyy-mm-dd',
                            readOnly: true,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (date != null) {
                                _endDateController.text =
                                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Shift
                          _buildLabel('Shift'),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedShift,
                            hint: 'Select Shift',
                            items: _shiftOptions.keys.toList(),
                            itemLabels: _shiftOptions,
                            onChanged: (val) {
                              setState(() {
                                _selectedShift = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Pay Type
                          _buildLabel('Pay Type'),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _payType,
                            hint: 'Select Pay Type',
                            items: _payTypeOptions.keys.toList(),
                            itemLabels: _payTypeOptions,
                            onChanged: (value) {
                              setState(() {
                                _payType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Pay Amount
                          _buildLabel('Pay Amount (₹)'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _payAmountController,
                            hint: 'Enter Pay Amount',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),

                          // Advance Payment
                          _buildLabel('Advance Payment'),
                          const SizedBox(height: 8),
                          _buildCheckbox(
                              'Advance Payment Required', _advancePayment, () {
                            setState(() {
                              _advancePayment = !_advancePayment;
                            });
                          }),
                          const SizedBox(height: 16),

                          // Advance Amount (only show if advance payment is enabled)
                          if (_advancePayment) ...[
                            _buildLabel('Advance Amount (₹)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _advanceAmountController,
                              hint: 'Enter Advance Amount',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _saveChanges();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showDeleteDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Delete Job',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    Map<String, String>? itemLabels,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: const TextStyle(color: Colors.black38, fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items.map((code) {
            return DropdownMenuItem<String>(
              value: code,
              child: Text(
                itemLabels != null ? itemLabels[code] ?? code : code,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? const Color(0xFF2E7D32) : Colors.white,
              border: Border.all(
                color: value ? const Color(0xFF2E7D32) : Colors.black54,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> availableItems,
    required List<String> selectedItems,
    required ValueChanged<List<String>> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableItems.map((item) {
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onTap: () {
            final newSelection = List<String>.from(selectedItems);
            if (isSelected) {
              newSelection.remove(item);
            } else {
              newSelection.add(item);
            }
            onChanged(newSelection);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.black54,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  const Icon(Icons.check, size: 16, color: Colors.white),
                if (isSelected) const SizedBox(width: 4),
                Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _saveChanges() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required fields
    if (_jobTitleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter job title');
      return;
    }

    if (_locationController.text.trim().isEmpty) {
      _showErrorDialog('Please enter location');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      _showErrorDialog('Please enter address');
      return;
    }

    if (_workersRequiredController.text.trim().isEmpty) {
      _showErrorDialog('Please enter number of workers required');
      return;
    }

    // Validate workers required is a valid number
    final workersValue = int.tryParse(_workersRequiredController.text.trim());
    if (workersValue == null || workersValue <= 0) {
      _showErrorDialog(
          'Please enter a valid number of workers (greater than 0)');
      return;
    }

    if (_skillsRequired.isEmpty) {
      _showErrorDialog('Please select at least one required skill');
      return;
    }

    if (_payAmountController.text.trim().isEmpty) {
      _showErrorDialog('Please enter pay amount');
      return;
    }

    // Validate pay amount is a valid number (accepts both int and decimal
    final payAmountValue = double.tryParse(_payAmountController.text.trim());
    if (payAmountValue == null || payAmountValue <= 0) {
      _showErrorDialog('Please enter a valid pay amount (numbers only)');
      return;
    }

    if (_startDateController.text.trim().isEmpty) {
      _showErrorDialog('Please select start date');
      return;
    }

    if (_endDateController.text.trim().isEmpty) {
      _showErrorDialog('Please select end date');
      return;
    }

    if (_selectedShift == null) {
      _showErrorDialog('Please select shift');
      return;
    }

    if (_advancePayment && _advanceAmountController.text.trim().isEmpty) {
      _showErrorDialog('Please enter advance amount');
      return;
    }

    if (_advancePayment) {
      final advanceAmountValue =
          double.tryParse(_advanceAmountController.text.trim());
      if (advanceAmountValue == null || advanceAmountValue <= 0) {
        _showErrorDialog('Please enter a valid advance amount (numbers only)');
        return;
      }
    }

    try {
      // Get job ID from jobData
      final jobId = widget.jobData['id']?.toString();
      if (jobId == null) {
        _showErrorDialog('Job ID not found');
        return;
      }

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );

      // Prepare job data (all values are already validated above)
      final jobData = {
        'job_title': _jobTitleController.text.trim(),
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        'job_type': _jobType,
        'workers_required': int.parse(_workersRequiredController.text.trim()),
        'skills_required': _skillsRequired,
        'tools_provided': _toolsProvided,
        'documents_required': _documentsRequired,
        'safety_instructions': _safetyInstructionsController.text.trim(),
        'start_date': _startDateController.text.trim(),
        'end_date': _endDateController.text.trim(),
        'shift': _selectedShift,
        'pay_type': _payType,
        'pay_amount': double.parse(_payAmountController.text.trim()).toInt(),
        'advance_payment': _advancePayment,
        'advance_amount': _advancePayment
            ? double.parse(_advanceAmountController.text.trim()).toInt()
            : 0,
      };

      print(" Sending job data: $jobData");

      // Call update API using AuthService
      await _authService.updateJob(jobId, jobData);

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      // Success - show success message and navigate back
      _showSuccessDialog('Job updated successfully');
    } catch (e) {
      // Close loading if still showing
      if (mounted) {
        Navigator.pop(context);
      }
      print("Error updating job: $e");
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _deleteJob() async {
    try {
      // Get job ID from jobData
      final jobId = widget.jobData['id']?.toString();
      if (jobId == null) {
        _showErrorDialog('Job ID not found');
        return;
      }

      // Show loading indicator
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
        ),
      );

      await _authService.deleteJob(jobId);

      // Close loading indicator
      if (!mounted) return;
      Navigator.pop(context);

      _showSuccessDialog('Job deleted successfully');
    } catch (e) {
      // Close loading if still showing
      if (mounted) {
        Navigator.pop(context);
      }
      print("Error deleting job: $e");
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5E6B3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context,
                    true); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF5E6B3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFF5E6B3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.priority_high,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Warning',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This action cannot be undone. Are you sure you want to delete this job?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _deleteJob(); // Call delete API
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Delete Job'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
