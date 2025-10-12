class CreateJobRequest {
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

  CreateJobRequest({
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
  });

  Map<String, dynamic> toJson() {
    return {
      "job_title": jobTitle,
      "location": location,
      "address": address,
      "job_type": jobType,
      "workers_required": workersRequired,
      "skills_required": skillsRequired,
      "tools_provided": toolsProvided,
      "documents_required": documentsRequired,
      "safety_instructions": safetyInstructions,
      "start_date": startDate,
      "end_date": endDate,
      "shift": shift,
      "pay_type": payType,
      "pay_amount": payAmount,
      "advance_payment": advancePayment,
      "advance_amount": advanceAmount,
    };
  }
}
