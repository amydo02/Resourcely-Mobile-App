import 'package:flutter/material.dart';
import '../../controllers/scholarship_controller.dart';
import '../../models/scholarship_model.dart';
import '../../utils/brand_colors.dart';
import '../../widgets/scholarship_card.dart';

class ScholarshipsScreen extends StatefulWidget {
  const ScholarshipsScreen({super.key});

  @override
  State<ScholarshipsScreen> createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends State<ScholarshipsScreen> {
  final _scholarshipController = ScholarshipController();
  final _searchController = TextEditingController();
  List<ScholarshipModel> _displayedScholarships = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScholarships();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadScholarships() async {
    await _scholarshipController.loadScholarships();
    if (mounted) {
      setState(() {
        _displayedScholarships = _scholarshipController.scholarships;
        _isLoading = false;
      });
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _displayedScholarships = _scholarshipController.searchScholarships(query);
    });
  }

  void _handleApply(String scholarshipId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Application submitted!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.lightSurface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scholarships',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: BrandColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Search Field
                    TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      decoration: InputDecoration(
                        hintText: 'Search scholarships...',
                        hintStyle: const TextStyle(color: BrandColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: BrandColors.slateGray),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Scholarships List
                    if (_displayedScholarships.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Text(
                            'No scholarships found',
                            style: TextStyle(
                              color: BrandColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _displayedScholarships.length,
                        itemBuilder: (context, index) {
                          final scholarship = _displayedScholarships[index];
                          return ScholarshipCard(
                            scholarship: scholarship,
                            onApplyPressed: () => _handleApply(scholarship.id),
                          );
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}