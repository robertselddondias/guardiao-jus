import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/repositories/company_repository.dart';
import 'package:guardiao_cliente/repositories/notification_repository.dart';
import 'package:guardiao_cliente/repositories/scheduler_repository.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/company_actions_screen.dart';
import 'package:guardiao_cliente/ui/company_list_screen.dart';
import 'package:guardiao_cliente/ui/payment_list_screen.dart';
import 'package:guardiao_cliente/ui/process_list_screen.dart';
import 'package:guardiao_cliente/ui/rap_list_screen.dart';
import 'package:guardiao_cliente/ui/schedule_all_screen.dart';
import 'package:guardiao_cliente/ui/settings_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeController extends GetxController {

  Rx<UserModel> userModel = UserModel().obs;

  final UserRepository _userRepository = UserRepository();
  final CompanyRepository _companyRepository = CompanyRepository();
  final NotificationRepository _notificationRepository = NotificationRepository();

  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  RxInt unreadNotifications = 0.obs;

  RxList<VoidCallback> listActions = <VoidCallback>[].obs;
  RxBool isPlanoAtivo = false.obs;

  final List<bool> featureEnabled = [
    true,
    true,
    true,
    Preferences.getString('companyId').isNotEmpty,
    Preferences.getString('companyId').isNotEmpty,
    true
  ];

  final List<bool> isBadge = [
    false,
    true,
    false,
    false,
    false,
    false
  ];

  RxInt totalSchehdules = 0.obs;

  final List<IconData> featureIcons = [
    Icons.policy_outlined,
    Icons.calendar_today_outlined,
    Icons.folder_open_outlined,
    Icons.balance_outlined,
    Icons.attach_money_outlined,
    Icons.settings_outlined,
  ];

  final List<String> featureLabels = [
    'Convênio Jurídico',
    'Agenda',
    'RAP',
    'Minhas Solicitações',
    'Pagamentos',
    'Configurações',
  ];

  final List<Color> featureColors = [
    const Color(0xFF78909C), // Azul-acinzentado claro, moderno e equilibrado
    const Color(0xFFB0BEC5), // Cinza pastel suave para suporte e equilíbrio
    const Color(0xFF66BB6A), // Verde pastel sofisticado e revitalizante
    const Color(0xFFFF5722), // Amarelo quente e acolhedor para itens de atenção
    const Color(0xFF42A5F5), // Azul turquesa vibrante para informações
    const Color(0xFF90CAF9), // Azul claro suave para itens decorativos e neutros
  ];


  @override
  void onInit() async{
    super.onInit();

    Preferences.getString('companyId');

    fetchUpcomingSchedulesCount();
    loadThemePreference();
    isPlanoAtivo.value = Preferences.getString('companyId').isNotEmpty;

    fetchUnreadNotifications();
    configureListActions();
  }

  void configureListActions() {
    listActions.value = [
      fetchCompanyVerify,
          () => Get.to(() => ScheduleAllScreen()), // Agenda
          () => Get.to(() => RapListScreen()),    // RAP
          () => Get.to(() => ProcessListScreen()),    // Processos
          () => Get.to(() => PaymentListScreen()), // Pagamentos
          () => Get.to(() => SettingsScreen()),   // Configurações
    ];
  }

  Future<void> fetchCompanyVerify() async {
    try {
      // Lógica principal para buscar os dados
      UserModel userModel = await _userRepository.getUserById();

      if (userModel.isPlanoAtivo!) {
        CompanyModel? company = await _companyRepository.getCompanyById(userModel.companyId!);
        Get.to(() => CompanyActionsScreen(company: company!));
      } else {
        Get.to(() => const CompanyListScreen());
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao verificar convênio: $e');
    }
  }

  Future<void> fetchUpcomingSchedulesCount() async {
    totalSchehdules.value = await _scheduleRepository.getUpcomingSchedulesCount();
  }

  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void fetchUnreadNotifications() async {
    _notificationRepository.listenUnreadCount().listen((count) {
      unreadNotifications.value = count;
    });
  }
}