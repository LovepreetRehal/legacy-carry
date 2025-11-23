import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/applicants_viewmodel.dart';

class ApplicantsScreen extends StatefulWidget {
  final String jobId;

  const ApplicantsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  late ApplicantsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ApplicantsViewModel();
    // Fetch applications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.fetchApplications(widget.jobId);
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6C945), Color(0xFF7BC57B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top AppBar Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 28),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "Applicants",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<ApplicantsViewModel>(
                    builder: (context, viewModel, child) {
                      if (viewModel.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        );
                      }

                      if (viewModel.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                viewModel.errorMessage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  viewModel.fetchApplications(widget.jobId);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (viewModel.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.people_outline,
                                size: 64,
                                color: Colors.black54,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No applicants yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Check back later for new applications',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await viewModel.refreshApplications();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: viewModel.applications.length,
                          itemBuilder: (context, index) {
                            final application = viewModel.applications[index];
                            return ApplicantCard(
                              application: application,
                              viewModel: viewModel,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ApplicantCard extends StatelessWidget {
  final dynamic application;
  final ApplicantsViewModel viewModel;

  const ApplicantCard({
    Key? key,
    required this.application,
    required this.viewModel,
  }) : super(key: key);

  String get _name {
    return application['name']?.toString() ??
        application['user_detils']?['name']?.toString() ??
        'Unknown';
  }

  String get _skills {
    return application['services']?.toString() ?? 'No services listed';
  }

  String get _message {
    final message = application['message_to_employer']?.toString();
    final about = application['about']?.toString();
    if (message != null && message.isNotEmpty) {
      return message;
    } else if (about != null && about.isNotEmpty) {
      return about;
    }
    return 'No message provided';
  }

  String? get _avatarUrl {
    final avatar = application['avatar']?.toString();
    final userAvatar = application['user_detils']?['avatar']?.toString();
    final avatarToUse = avatar ?? userAvatar;

    if (avatarToUse != null && avatarToUse.isNotEmpty) {
      // If it's already a full URL, return as is
      if (avatarToUse.startsWith('http://') ||
          avatarToUse.startsWith('https://')) {
        return avatarToUse;
      }
      // If it's a relative URL, prepend the base URL
      String cleanUrl =
          avatarToUse.startsWith('/') ? avatarToUse.substring(1) : avatarToUse;
      return '${viewModel.baseUrlWithoutApi}/$cleanUrl';
    }
    return null;
  }

  bool get _isShortlisted {
    return application['shortlisted'] == 1 ||
        application['shortlisted'] == true ||
        application['status']?.toString().toLowerCase() == 'shortlisted';
  }

  bool get _isHired {
    return application['status']?.toString().toLowerCase() == 'hired';
  }

  int? get _applicationId {
    final id = application['application_id'];
    if (id == null) return null;
    return int.tryParse(id.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                backgroundImage:
                    _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                onBackgroundImageError: _avatarUrl != null
                    ? (exception, stackTrace) {
                        print("Error loading avatar: $exception");
                        print("URL was: $_avatarUrl");
                      }
                    : null,
                child: _avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 28)
                    : null,
              ),
              const SizedBox(width: 10),

              // Name & Skills
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _skills,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Status indicator (Hired, Shortlisted, or rating placeholder)
              if (_isHired)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade900, width: 1),
                  ),
                  child: const Text(
                    "Hired",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (_isShortlisted)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 1),
                  ),
                  child: const Text(
                    "Shortlisted",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                )
              else
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.orange, size: 20),
                    Text("4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 6),
          Text(
            _message,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // Buttons
          Consumer<ApplicantsViewModel>(
            builder: (context, vm, child) {
              final isHiringThis = _applicationId != null &&
                  vm.isHiringApplication(_applicationId!);

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _smallBtn(
                    "Shortlist",
                    _isShortlisted ? Colors.green : Colors.grey.shade300,
                    _isShortlisted ? Colors.white : Colors.black,
                    isLoading: isHiringThis,
                    onTap: _isHired
                        ? null
                        : () async {
                            if (_applicationId == null) return;
                            final success = await vm.shortlistApplicant(
                                _applicationId!, !_isShortlisted);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? (_isShortlisted
                                            ? 'Removed from shortlist'
                                            : 'Shortlisted successfully')
                                        : vm.errorMessage,
                                  ),
                                  backgroundColor:
                                      success ? Colors.green : Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                  ),
                  _smallBtn(
                    _isHired ? "Hired" : "Hire",
                    _isHired ? Colors.grey : Colors.green,
                    Colors.white,
                    isLoading: isHiringThis,
                    onTap: _isHired
                        ? null
                        : () async {
                            if (_applicationId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Application ID not found'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hire Applicant'),
                                content: Text(
                                    'Are you sure you want to hire $_name?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Hire'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;

                            final success =
                                await vm.hireApplicant(_applicationId!);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Applicant hired successfully!'
                                        : vm.errorMessage,
                                  ),
                                  backgroundColor:
                                      success ? Colors.green : Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                  ),
                  _smallBtn(
                    "Message",
                    Colors.black,
                    Colors.white,
                    isLoading: false,
                    onTap: () {
                      // TODO: Implement message functionality
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }

  Widget _smallBtn(
    String text,
    Color bg,
    Color textColor, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isLoading || onTap == null ? null : onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 36,
          decoration: BoxDecoration(
            color: (isLoading || onTap == null) ? bg.withOpacity(0.6) : bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
