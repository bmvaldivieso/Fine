import 'package:get/get.dart';
import 'package:lms_english_app/features/home/views/review_submission_view.dart';
import 'package:lms_english_app/features/home/views/submit_homework_view.dart';
import '../../auth/register/register.dart';
import '../../auth/register/represent_form.dart';
import '../../auth/register/user_form.dart';
import '../../auth/register/codig_Verificacion.dart';
import '../../auth/register/welcome_end.dart';

class HomeController extends GetxController {
  RxInt currentIndex = 0.obs;
  Rxn<Map<String, dynamic>> tareaSeleccionada = Rxn<Map<String, dynamic>>();


  void goToSubmitHomeworkInterno(Map<String, dynamic> tarea) {
    tareaSeleccionada.value = tarea;
    currentIndex.value = 9; 
  }

  void changeTab(int index) {
    currentIndex.value = index;
    print("si llegooooooooooo");
    print(currentIndex.value);
  }

  void goToRegistro() {
    Get.to(
      () => const RegisterScreen(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToRepresentRegister() {
    Get.to(
      () => const RegisterScreenRepresentante(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToUserRegister() {
    Get.to(
      () => const RegisterScreenUser(),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void gotoCodigoVerifi() {
    Get.to(
      () => const codigVerifi(),
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
    Get.offAll(
      () => WelcomeScreen(userName: userName),
      transition: Transition.fade,
      duration: const Duration(milliseconds: 500),
    );
  }

  void goToSubmitHomework(Map<String, dynamic> asignacion) {
    Get.to(
      () => SubmitHomeworkView(asignacion: asignacion),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  void goToReviewSubmission(Map<String, dynamic> asignacion) {
    Get.to(
      () => ReviewSubmissionView(asignacion: asignacion),
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 300),
    );
  }
}
