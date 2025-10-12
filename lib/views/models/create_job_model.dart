// models/create_job_response.dart

class Job {
  final int id;
  final String jobTitle;
  final String location;
  final String address;
  final String jobType;
  final int workersRequired;
  final List<String> skillsRequired;
  final bool toolsProvided;
  final List<String> documentsRequired;
  final String safetyInstructions;
  final String startDate;
  final String endDate;
  final String shift;
  final String payType;
  final int payAmount;
  final bool advancePayment;
  final int advanceAmount;
  final String createdAt;
  final String updatedAt;

  Job({
    required this.id,
    required this.jobTitle,
    required this.location,
    required this.address,
    required this.jobType,
    required this.workersRequired,
    required this.skillsRequired,
    required this.toolsProvided,
    required this.documentsRequired,
    required this.safetyInstructions,
    required this.startDate,
    required this.endDate,
    required this.shift,
    required this.payType,
    required this.payAmount,
    required this.advancePayment,
    required this.advanceAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      jobTitle: json['job_title'],
      location: json['location'],
      address: json['address'],
      jobType: json['job_type'],
      workersRequired: json['workers_required'],
      skillsRequired: List<String>.from(json['skills_required'] ?? []),
      toolsProvided: json['tools_provided'],
      documentsRequired: List<String>.from(json['documents_required'] ?? []),
      safetyInstructions: json['safety_instructions'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      shift: json['shift'],
      payType: json['pay_type'],
      payAmount: json['pay_amount'],
      advancePayment: json['advance_payment'],
      advanceAmount: json['advance_amount'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class CreateJobResponse {
  final String message;
  final Job data;

  CreateJobResponse({
    required this.message,
    required this.data,
  });

  factory CreateJobResponse.fromJson(Map<String, dynamic> json) {
    return CreateJobResponse(
      message: json['message'],
      data: Job.fromJson(json['data']),
    );
  }
}
