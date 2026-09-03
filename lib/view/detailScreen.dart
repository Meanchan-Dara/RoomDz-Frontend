import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/util/google_map_util.dart';

class Detailscreen extends StatelessWidget {
  final String imageUrl;

  final double latitude = 11.5714;
  final double longitude = 104.8988;

  Detailscreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final LatLng roomLocation = LatLng(latitude, longitude);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leadingWidth: 60,
            actionsPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white60,
                  ),
                  child: const Icon(Icons.arrow_back_outlined),
                ),
              ),
            ),
            actions: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white60,
                ),
                child: const Icon(Icons.share),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white60,
                ),
                child: const Icon(Icons.favorite_outline),
              ),
            ],
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Title of contents",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.star, size: 18, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        "2.5",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined),
                      const SizedBox(width: 5),
                      const Text('Toul Kork, Phnom Penh'),
                      const Spacer(),
                      Text(
                        "\$150",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 24,
                        ),
                      ),
                      const Text(' / មួយខែ', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(thickness: .8),
                  const SizedBox(height: 8),
                  const Text(
                    "អំពីបន្ទប់",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "បន្ទប់មានទំហំប្រហែល 25m² មានបន្ទប់គេង 1 និងបន្ទប់ទឹក 1។ "
                    "មានគ្រឿងសង្ហារឹមមូលដ្ឋាន ដូចជា គ្រែ ទូខោអាវ តុ និងកៅអី។ "
                    "មាន Wi-Fi និងទឹកប្រើប្រាស់ ហើយទីតាំងស្ថិតនៅជិតផ្សារ សាលារៀន "
                    "និងហាងលក់ទំនិញ។",
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBgContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "ព័ត៌មានបន្ទប់",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              size: 22,
                              color: Colors.blueGrey.shade700,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "ប្រភេទ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "បន្ទប់ឯកជន",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(thickness: 0.7, color: Colors.grey.shade200),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              Icons.straighten_outlined,
                              size: 22,
                              color: Colors.blueGrey.shade700,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "ទំហំ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "24 sqm",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(thickness: 0.7, color: Colors.grey.shade200),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              Icons.layers_outlined,
                              size: 22,
                              color: Colors.blueGrey.shade700,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "ជាន់",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "ជាន់ទី​ 3 ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Divider(thickness: 0.7, color: Colors.grey.shade200),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(
                              Icons.key_outlined,
                              size: 22,
                              color: Colors.blueGrey.shade700,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              "ប្រាក់កក់",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey.shade700,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              "1 ខែ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBgContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "ច្បាប់សម្រាប់អ្នកជួល",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "• ហាមជក់បារីនៅក្នុងបន្ទប់。\n"
                          "• ត្រូវរក្សាអនាម័យ និងសណ្តាប់ធ្នាប់ជាប្រចាំ。\n"
                          "• មិនអនុញ្ញាតឱ្យធ្វើសកម្មភាពដែលបង្កសំឡេងរំខាន。\n"
                          "• ត្រូវបង់ថ្លៃជួលតាមកាលកំណត់。\n"
                          "• ប្រសិនបើមានការខូចខាត ត្រូវជូនដំណឹងទៅម្ចាស់បន្ទប់。\n"
                          "• មិនអនុញ្ញាតឱ្យផ្ទេរសិទ្ធិជួលទៅអ្នកផ្សេងដោយគ្មានការយល់ព្រម。\n"
                          "• ត្រូវគោរពច្បាប់ និងបទបញ្ជារបស់អគារ。",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.7,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildBgContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ទីតាំង',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => GoogleMapUtil.openGoogleMaps(
                                latitude: latitude,
                                longitude: longitude,
                              ),
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Google Maps'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FlutterMap(
                            options: MapOptions(
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                              initialCenter: roomLocation,
                              initialZoom: 15.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.roomdz_frontend',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: roomLocation,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "តម្លៃ",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "\$150",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(" / មួយខែ", style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(180, 40),
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                "ស្នើសុំមើលផ្ទាល់",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBgContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
