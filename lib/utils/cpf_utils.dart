class CpfUtil {
  /// Valida se o CPF fornecido é válido.
  /// Retorna `true` para CPF válido e `false` caso contrário.
  static bool isValid(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    // Verifica se o CPF tem 11 dígitos ou é uma sequência inválida (111.111.111-11, etc.)
    if (cpf.length != 11 || RegExp(r'^(\d)\1*$').hasMatch(cpf)) {
      return false;
    }

    // Calcula os dígitos verificadores
    int calcularDigito(List<int> numeros) {
      int soma = 0;
      for (int i = 0; i < numeros.length; i++) {
        soma += numeros[i] * (numeros.length + 1 - i);
      }
      int resto = soma % 11;
      return resto < 2 ? 0 : 11 - resto;
    }

    List<int> numeros = cpf.split('').map(int.parse).toList();
    int digito1 = calcularDigito(numeros.sublist(0, 9));
    int digito2 = calcularDigito(numeros.sublist(0, 10));

    // Verifica se os dígitos calculados são iguais aos fornecidos
    return digito1 == numeros[9] && digito2 == numeros[10];
  }

  /// Formata o CPF fornecido no formato 000.000.000-00.
  /// Retorna o CPF formatado ou uma string vazia se o CPF for inválido.
  static String format(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    // Verifica se o CPF tem 11 dígitos
    if (cpf.length != 11) {
      return '';
    }

    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }

  /// Remove a formatação do CPF.
  /// Retorna apenas os números do CPF.
  static String unformat(String cpf) {
    return cpf.replaceAll(RegExp(r'\D'), '');
  }
}
