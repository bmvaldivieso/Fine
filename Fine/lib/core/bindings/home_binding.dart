import 'package:get/get.dart';
import '../../features/home/controllers/home_Controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
