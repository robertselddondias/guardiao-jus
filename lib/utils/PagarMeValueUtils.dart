import 'package:intl/intl.dart';

class PagarMeValueUtils {
  // Formatador de moeda brasileira
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  /// Converte valor em centavos (int) para formato de exibição (String)
  /// Exemplo: 100 centavos → "R\$ 1,00"
  static String centavosToDisplay(int centavos) {
    double valor = centavos / 100.0;
    return _currencyFormatter.format(valor);
  }

  /// Converte valor em centavos (int) para double
  /// Exemplo: 100 centavos → 1.00
  static double centavosToDouble(int centavos) {
    return centavos / 100.0;
  }

  /// Converte valor em reais (double) para centavos (int)
  /// Exemplo: 1.50 → 150 centavos
  static int realToCentavos(double reais) {
    return (reais * 100).round();
  }

  /// Converte string de valor para centavos
  /// Exemplo: "1,50" → 150 centavos
  static int stringToCentavos(String valor) {
    // Remove símbolos e espaços
    String cleanValue = valor
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '') // Remove separador de milhares
        .replaceAll(',', '.'); // Troca vírgula decimal por ponto

    double reais = double.tryParse(cleanValue) ?? 0.0;
    return realToCentavos(reais);
  }

  /// Formata valor sem o símbolo da moeda
  /// Exemplo: 150 centavos → "1,50"
  static String centavosToStringWithoutSymbol(int centavos) {
    double valor = centavos / 100.0;
    return NumberFormat('#,##0.00', 'pt_BR').format(valor);
  }
}