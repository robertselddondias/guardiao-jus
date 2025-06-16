import 'dart:convert';

import 'package:http/http.dart' as http;

class CepService {
  // Função para buscar informações de endereço a partir do CEP
  Future<Map<String, dynamic>?> fetchAddressFromCep(String cep) async {
    final url = 'https://viacep.com.br/ws/$cep/json/';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Verifica se o retorno é válido
        if (data.containsKey('erro')) {
          return null; // Retorna null se o CEP for inválido
        }

        return data;
      } else {
        return null; // Retorna null em caso de erro de requisição
      }
    } catch (e) {
      rethrow; // Propaga o erro para ser tratado externamente
    }
  }
}
