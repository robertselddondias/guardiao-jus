import 'package:dio/dio.dart';

class ProcessoApiService {
  final Dio _dio = Dio();

  static const String _baseUrl = "https://api-publica.datajud.cnj.jus.br/api_publica_tjdft/_search";
  static const String _apiKey = "APIKey cDZHYzlZa0JadVREZDJCendQbXY6SkJlTzNjLV9TRENyQk1RdnFKZGRQdw==";

  ProcessoApiService() {
    _dio.options.headers = {
      "Authorization": _apiKey,
      "Content-Type": "application/json",
    };
  }

  /// Consulta processo por número
  Future<Map<String, dynamic>?> consultarProcesso(String numeroProcesso) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          "query": {
            "match": {
              "numeroProcesso": numeroProcesso
            }
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data["hits"]["total"]["value"] > 0) {
          return data["hits"]["hits"][0]["_source"];
        } else {
          return null;
        }
      } else {
        throw Exception("Erro ao buscar processo. Código: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição: $e");
      return null;
    }
  }
}