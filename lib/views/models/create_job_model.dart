import 'dart:convert';
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
    List<String> parseStringOrList(dynamic value) {
      if (value is List) {
        return List<String>.from(value);
      } else if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return List<String>.from(decoded);
          }
        } catch (_) {}
        return [];
      }
      return [];
    }

    // Helper to parse int values
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Helper to parse bool values
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return Job(
      id: parseInt(json['id']),
      jobTitle: (json['job_title'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      jobType: (json['job_type'] ?? '').toString(),
      workersRequired: parseInt(json['workers_required']),
      skillsRequired: parseStringOrList(json['skills_required']),
      toolsProvided: parseBool(json['tools_provided']),
      documentsRequired: parseStringOrList(json['documents_required']),
      safetyInstructions: (json['safety_instructions'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      shift: (json['shift'] ?? '').toString(),
      payType: (json['pay_type'] ?? '').toString(),
      payAmount: parseInt(json['pay_amount']),
      advancePayment: parseBool(json['advance_payment']),
      advanceAmount: parseInt(json['advance_amount']),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
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
      message: json['message'] ?? 'Job created successfully',
      data: Job.fromJson(json['data']),
    );
  }
}
