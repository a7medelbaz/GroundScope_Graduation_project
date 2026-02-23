import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportDetailsScreen extends StatelessWidget {
  ReportDetailsScreen({super.key});

  final String reportDescription =
      'This is a detailed report description. It contains information about the flight pushback operation, including any incidents, observations, or important notes that need to be documented.';

  final List<String> gridImageUrls = [
    'https://assets.isu.pub/document-structure/221123173321-2c17eb563de689811eb5a2aeff8a625e/v1/7ed169130ba23e8321bf75de993c4896.jpeg',
    'https://www.whkemp.co.uk/wp-content/uploads/Airports-and-Aircraft-Ground-Support-Equipment-1024x683.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Report Details',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flight BA2490 - A380 Pushback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const _DetailRow(icon: Icons.tag, label: 'Stand: C34'),
                const SizedBox(height: 10),
                const _DetailRow(
                  icon: Icons.schedule,
                  label: 'ETA: 13:00 - 13:15',
                ),
                const SizedBox(height: 10),
                const _DetailRow(icon: Icons.event, label: 'DATE: 27-04-2024'),
                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2A35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DESCRIPTION',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reportDescription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Image Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: List.generate(4, (index) {
                    final imageUrl = index < gridImageUrls.length
                        ? gridImageUrls[index]
                        : null;

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFF1A2633),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          color: const Color(0xFF2E8AF0),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF1A2633),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image,
                                      color: Color(0xFF586474),
                                      size: 32,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: const Color(0xFF1A2633),
                              child: const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Color(0xFF586474),
                                  size: 32,
                                ),
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8B95A5), size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8B95A5), fontSize: 15),
        ),
      ],
    );
  }
}
