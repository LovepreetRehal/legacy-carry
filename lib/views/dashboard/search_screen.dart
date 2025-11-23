import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../employe/job_detail_screen.dart';
import '../viewmodels/search_jobs_viewmodel.dart';

class SearchJobsScreen extends StatelessWidget {
  const SearchJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchJobsViewModel()..loadInitialJobs(),
      child: const _SearchJobsContent(),
    );
  }
}

class _SearchJobsContent extends StatefulWidget {
  const _SearchJobsContent();

  @override
  State<_SearchJobsContent> createState() => _SearchJobsContentState();
}

class _SearchJobsContentState extends State<_SearchJobsContent> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<SearchJobsViewModel>().searchJobs(keyword: value);
    });
  }

  void _clearSearch() {
    _controller.clear();
    context.read<SearchJobsViewModel>().searchJobs(keyword: '');
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SearchJobsViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDFB139),
              Color(0xFFB9AE3C),
              Color(0xFF3CA349),
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _controller,
                  onChanged: _onSearchChanged,
                  onSubmitted: (value) =>
                      context.read<SearchJobsViewModel>().searchJobs(
                            keyword: value,
                          ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    suffixIcon: viewModel.isLoading && viewModel.jobs.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_controller.text.isNotEmpty
                            ? IconButton(
                                onPressed: _clearSearch,
                                icon:
                                    const Icon(Icons.clear, color: Colors.red),
                              )
                            : null),
                    hintText: "Search jobs by skill or location",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildFilterButton("Skill")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFilterButton("Pay Range")),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildFilterButton("Shift")),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFilterButton("Date")),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildResults(viewModel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults(SearchJobsViewModel viewModel) {
    if (viewModel.status == SearchJobsStatus.loading &&
        viewModel.jobs.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    if (viewModel.status == SearchJobsStatus.error && viewModel.jobs.isEmpty) {
      return _buildErrorState(viewModel);
    }

    if (viewModel.jobs.isEmpty) {
      return Center(
        child: Text(
          'No jobs found.\nTry a different keyword.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.green[700],
      onRefresh: () => viewModel.searchJobs(keyword: viewModel.keyword.trim()),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final rawJob = viewModel.jobs[index];
          final job = rawJob is Map<String, dynamic>
              ? Map<String, dynamic>.from(rawJob)
              : <String, dynamic>{'job_title': rawJob.toString()};
          return _buildJobCard(context, job);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: viewModel.jobs.length,
      ),
    );
  }

  Widget _buildErrorState(SearchJobsViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              viewModel.errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                viewModel.searchJobs(keyword: viewModel.keyword.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final title = job['job_title']?.toString() ?? 'No Title';
    final location = job['location']?.toString() ??
        job['address']?.toString() ??
        'Location not provided';
    final status = job['status']?.toString() ?? 'draft';
    final shift = job['shift']?.toString() ?? 'N/A';
    final payAmount = job['pay_amount']?.toString() ?? '0';
    final payType = _formatPayType(job['pay_type']?.toString());
    final workersRequired = job['workers_required']?.toString() ??
        job['workers']?.toString() ??
        '0';
    final startDate = _formatDate(job['start_date']?.toString());
    final endDate = _formatDate(job['end_date']?.toString());
    final skills = _parseStringList(job['skills_required']);
    final documents = _parseStringList(job['documents_required']);

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'completed':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailScreen(jobData: job),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(startDate),
                if (endDate.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  const Text('–'),
                  const SizedBox(width: 4),
                  Text(endDate),
                ],
                const SizedBox(width: 12),
                Chip(
                  label: Text(
                    shift.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: Colors.green.withOpacity(0.15),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people, size: 18, color: Colors.blue),
                const SizedBox(width: 6),
                Text('$workersRequired Workers'),
                const Spacer(),
                const Icon(Icons.currency_rupee,
                    size: 18, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  '$payAmount / $payType',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: skills
                    .take(4)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(fontSize: 11),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (documents.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.assignment, size: 16, color: Colors.brown),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Documents: ${documents.join(', ')}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(jobData: job),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    final stringValue = value.toString();
    if (stringValue.isEmpty) return [];

    try {
      final decoded = jsonDecode(stringValue);
      if (decoded is List) {
        return decoded.map((item) => item.toString()).toList();
      }
    } catch (_) {
      // ignore decoding errors, fall back to comma separated parsing
    }

    return stringValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _formatPayType(String? raw) {
    if (raw == null || raw.isEmpty) return 'Day';
    final value = raw.replaceAll('_', ' ');
    return value
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final date = DateTime.parse(rawDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      final parts = rawDate.split('T');
      return parts.isNotEmpty ? parts.first : rawDate;
    }
  }
}
