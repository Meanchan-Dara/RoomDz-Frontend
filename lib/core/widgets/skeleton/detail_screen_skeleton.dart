import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class DetailScreenSkeleton extends StatelessWidget {
  const DetailScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Skeletonizer(
        enabled: true,
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            // Banner Header Skeleton
            SliverAppBar(
              leadingWidth: 60,
              actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.arrow_back_outlined),
                ),
              ),
              actions: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.share),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.favorite_outline),
                ),
              ],
              expandedHeight: 320,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(color: Colors.grey.shade300),
              ),
            ),

            // Content Skeleton Body
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Rating
                    Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Modern Luxury Apartment Room',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Icon(Icons.star, size: 18, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Address & Price
                    Row(
                      children: const [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text('Street 271, Phnom Penh, Cambodia'),
                        ),
                        Text(
                          '\$250',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(' / មួយខែ', style: TextStyle(fontSize: 18)),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Divider(thickness: 0.8),
                    const SizedBox(height: 8),

                    // About Room Placeholder
                    const Text(
                      'អំពីបន្ទប់',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This is a spacious and comfortable room equipped with modern furniture, private bathroom, and high-speed Wi-Fi connection.',
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),

                    const SizedBox(height: 16),

                    // Room Information Card
                    _buildBgContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'ព័ត៌មានបន្ទប់',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildInfoRow(
                            icon: Icons.meeting_room_outlined,
                            label: 'ប្រភេទ',
                            value: 'Studio Room',
                          ),
                          const SizedBox(height: 14),
                          Divider(thickness: 0.7, color: Colors.grey.shade200),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            icon: Icons.straighten_outlined,
                            label: 'ទំហំ',
                            value: '35 sq.m',
                          ),
                          const SizedBox(height: 14),
                          Divider(thickness: 0.7, color: Colors.grey.shade200),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            icon: Icons.layers_outlined,
                            label: 'ជាន់',
                            value: '3rd Floor',
                          ),
                          const SizedBox(height: 14),
                          Divider(thickness: 0.7, color: Colors.grey.shade200),
                          const SizedBox(height: 14),
                          _buildInfoRow(
                            icon: Icons.key_outlined,
                            label: 'ប្រាក់កក់',
                            value: '1 Month',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // House Rules Card
                    _buildBgContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'ច្បាប់សម្រាប់អ្នកជួល',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• No smoking inside\n• Keep noise low after 10 PM\n• Maintain cleanliness',
                            style: TextStyle(fontSize: 15, height: 1.7),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Location Card
                    _buildBgContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'ទីតាំង',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text('Google Maps'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Landlord Contact Card
                    _buildBgContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'បានចុះបញ្ជីដោយម្ចាស់ផ្ទះ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const CircleAvatar(radius: 28, child: Text('SV')),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Sophea Vorn',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text('Responds within 15 mins'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildBgContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }

  static Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
