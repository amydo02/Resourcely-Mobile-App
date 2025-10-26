import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/scholarship_controller.dart';
import '../../utils/brand_colors.dart';
import '../../widgets/quick_access_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  
  const HomeScreen({
    super.key,
    this.onNavigate,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scholarshipController = ScholarshipController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _scholarshipController.loadScholarships();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website')),
        );
      }
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.access_time, color: BrandColors.royalBlue),
            SizedBox(width: 8),
            Text(
              'Coming Soon!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.construction,
              size: 64,
              color: BrandColors.alertYellow,
            ),
            SizedBox(height: 16),
            Text(
              'AI Assistant is currently under development.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: BrandColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We\'re working hard to bring this feature to you soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: BrandColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.royalBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Got it!',
              style: TextStyle(color: BrandColors.lightSurface),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.lightSurface,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome, Spartan! 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Here's what's happening today",
                          style: TextStyle(
                            fontSize: 16,
                            color: BrandColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Stats Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: BrandColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: BrandColors.royalBlue.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quick Stats',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_scholarshipController.availableScholarshipsCount} New',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Scholarships available',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.card_giftcard,
                                size: 72,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        const Text(
                          'Quick Access',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Quick Access Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          children: [
                            QuickAccessCard(
                              icon: Icons.school_outlined,
                              title: 'Scholarships',
                              color: BrandColors.alertYellow,
                              onTap: () {
                                widget.onNavigate?.call(1);
                              },
                            ),
                            QuickAccessCard(
                              icon: Icons.directions_bus,
                              title: 'Transit',
                              color: BrandColors.highlightBlue,
                              onTap: () {
                                widget.onNavigate?.call(2);
                              },
                            ),
                            QuickAccessCard(
                              icon: Icons.volunteer_activism,
                              title: 'SJSU Care',
                              color: const Color.fromARGB(255, 94, 129, 244),
                              onTap: () {
                                _launchURL('https://www.sjsu.edu/sjsucares/resources/index.php');
                              },
                            ),
                            QuickAccessCard(
                              icon: Icons.calendar_today,
                              title: 'Calendar',
                              color: BrandColors.successGreen,
                              onTap: () {
                                widget.onNavigate?.call(3);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  
                  // Floating AI Assistant Button
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: _showComingSoonDialog,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color.fromARGB(255, 172, 173, 248), Color(0xFF8E44AD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 182, 183, 247).withOpacity(0.4),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.support_agent,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: BrandColors.alertYellow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: BrandColors.lightSurface,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: BrandColors.royalBlue.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'SOON',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}