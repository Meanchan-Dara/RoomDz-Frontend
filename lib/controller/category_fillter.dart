import 'package:get/get.dart';
import 'package:roomdz_frontend/model/categoryModel.dart';
import 'package:roomdz_frontend/viewmodel/viewCategory.dart';

class FilterCategory extends GetxController {
  RxList filterList = <Categories>[].obs;
  FilterCategory() {
    filterList = categories.obs;
  }
  void filter(String category){
    
  }
}
