import 'package:flutter/material.dart';
import 'package:roomdz_frontend/const/colors/appColors.dart';
import 'package:roomdz_frontend/viewmodel/viewCategory.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final TextEditingController _locationRoom = TextEditingController();
  int selectedCategories = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.symmetric(horizontal: 16),
        actions: [Icon(Icons.notifications_outlined, size: 32)],
        leading: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Dz-RoomFinder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // find buttom
              TextFormField(
                controller: _locationRoom,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  hintText: 'ស្វែងរកទីតាំងបន្ទប់....',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _locationRoom.clear();
                    },
                    child: Icon(Icons.close),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    "Current location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              //build category
              _buildCategory(),
              // body build
              // _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildBody() {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 600,
  //     child: ListView.builder(
  //       shrinkWrap: true,
  //       physics: NeverScrollableScrollPhysics(),
  //       itemBuilder: (context, index) {
  //         return Stack(
  //           children: [Container(width: 200, height: 200, color: Colors.red)],
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildCategory() {
    return SizedBox(
      height: 85,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category.icon, size: 30),
                  const SizedBox(height: 6),
                  Text(category.text, textAlign: TextAlign.center),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
