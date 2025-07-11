import 'package:get/get.dart';
import '../../auth/register/register.dart';
import '../../auth/register/represent_form.dart';
import '../../auth/register/user_form.dart';
import '../../auth/register/codig_Verificacion.dart';
import '../../auth/register/welcome_end.dart';



class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    print("si llegooooooooooo");
    print(currentIndex.value);
  }

  void goToRegistro() {
    Get.to(() => const RegisterScreen(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToRepresentRegister() {
    Get.to(() => const RegisterScreenRepresentante(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToUserRegister() {
    Get.to(() => const RegisterScreenUser(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void gotoCodigoVerifi() {
    Get.to(() => const codigVerifi(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }


  ///Punto Central del Home//
  void gotoHomeWithIndex(int index, {String transitionType = 'offAll'}) {
    final route = '/home?index=$index';
    switch (transitionType) {
      case 'offAll':
        Get.offAllNamed(route);
        break;
      case 'off':
        Get.offNamed(route);
        break;
      case 'to':
        Get.toNamed(route);
        break;
      default:
        Get.toNamed(route);
    }
  }


  void gotoWelcome(String userName) {
    Get.offAll(() => WelcomeScreen(userName: userName),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

}
