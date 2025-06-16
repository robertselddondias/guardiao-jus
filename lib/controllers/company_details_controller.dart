import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/company_model.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/contract_confirmation_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyDetailsController extends GetxController {

  // Modelo da empresa em formato reativo
  final Rx<CompanyModel> company = CompanyModel().obs;

  // Estado de carregamento para download ou outras operações
  final RxBool isLoading = false.obs;

  // Define o modelo da empresa
  void setCompany(CompanyModel newCompany) {
    company.value = newCompany;
  }


  // Método para baixar contrato
  Future<String?> downloadContract() async {
    if (company.value.urlContract == null) return null;

    try {
      isLoading.value = true;

      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/contrato_${company.value.name}.pdf';

      // Faz o download do PDF
      await dio.download(company.value.urlContract!, filePath);

      isLoading.value = false;
      return filePath;
    } catch (e) {
      isLoading.value = false;
      return null;
    }
  }

  // Método para confirmar o contrato
  void confirmContract() async {
    Get.to(() => ContractConfirmationScreen(), arguments: {'company': company.value});
  }

  void openWhatsApp(String? phone) {
    if (phone == null || phone.isEmpty) {
      SnackbarCustom.showError('Número de telefone não disponível.');
      return;
    }

    final formattedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = 'https://wa.me/$formattedPhone';

    launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication).catchError((e) {
      SnackbarCustom.showError('Não foi possível abrir o WhatsApp.');
    });
  }
}
