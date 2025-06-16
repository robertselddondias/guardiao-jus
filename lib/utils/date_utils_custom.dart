

import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class DateUtilsCustom {

  static String formatDate(String createdAt) {
    try {
      // Defina o formato esperado da string original
      final originalFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ"); // Ajuste conforme o padrão da string
      final parsedDate = originalFormat.parse(createdAt, true);

      // Formate a data no padrão desejado
      final outputFormat = DateFormat("dd/MM/yyyy");
      return outputFormat.format(parsedDate);
    } catch (e) {
      return "Data inválida"; // Retorno em caso de erro
    }
  }

  static String formatDateStringToBrasilDateString(String createdAt) {
    try {
      // Defina o formato esperado da string original
      final originalFormat = DateFormat("yyyy-MM-dd"); // Ajuste conforme o padrão da string
      final parsedDate = originalFormat.parse(createdAt, true);

      // Formate a data no padrão desejado
      final outputFormat = DateFormat("dd/MM/yyyy");
      return outputFormat.format(parsedDate);
    } catch (e) {
      return "Data inválida"; // Retorno em caso de erro
    }
  }

  static String formatDateToBrazil(DateTime createdAt) {
    try {
      // Formate a data no padrão desejado
      final outputFormat = DateFormat("dd/MM/yyyy");
      return outputFormat.format(createdAt);
    } catch (e) {
      return "Data inválida"; // Retorno em caso de erro
    }
  }

  static String formatDateISO(String formatDate) {
    try {
      final originalFormat = DateFormat("dd/MM/yyyy"); // Ajuste conforme o padrão da string
      return originalFormat.parse(formatDate, true).toIso8601String();
    } catch (e) {
      return "Data inválida"; // Retorno em caso de erro
    }
  }

  static DateTime convertToSchedulerDateTime(String dateString) {
    try {
      // Criando um DateFormat com o padrão fornecido
      DateFormat inputFormat = DateFormat("dd/MM/yyyy HH:mm");

      // Convertendo a string para DateTime
      DateTime parsedDate = inputFormat.parse(dateString);

      return parsedDate;
    } catch (e) {
      throw Exception("Erro ao converter data: Formato inválido.");
    }
  }

  static DateTime? convertStringToDate(String dateString) {
    try {
      DateFormat format = DateFormat("dd/MM/yyyy");
      return format.parse(dateString);
    } catch (e) {
      print("Erro ao converter data: $e");
      return null;
    }
  }

  static DateTime convertDateToDateTime(DateTime dateTime) {
    try {
      // Formata a data para o padrão "dd/MM/yyyy HH:mm"
      String formattedDate = DateFormat("dd/MM/yyyy HH:mm").format(dateTime);

      // Converte a string formatada de volta para DateTime (Garante precisão)
      return DateFormat("dd/MM/yyyy HH:mm").parse(formattedDate);
    } catch (e) {
      throw Exception("Erro ao converter data: Formato inválido.");
    }
  }

  static tz.TZDateTime convertToFutureTZDateTime(DateTime dateTime) {
    // 🔹 Inicializa a Timezone apenas uma vez
    tz.initializeTimeZones();

    // 🔹 Define o fuso horário padrão como "America/Sao_Paulo" (ou outro conforme sua necessidade)
    final location = tz.getLocation('America/Sao_Paulo');

    // 🔹 Converte o DateTime para TZDateTime
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, location);

    // 🔹 Se a data estiver no passado, define para o próximo dia no mesmo horário
    if (scheduledDate.isBefore(tz.TZDateTime.now(location))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

}