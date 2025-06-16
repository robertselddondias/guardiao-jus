import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guardiao_cliente/models/entidade_militar_model.dart';

class EntidadeMilitarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String collectionName = "instituicoes";


  Future<List<EntidadeMilitarModel>> fetchByEstado(String estado) async {
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('estado', isEqualTo: estado)
          .get();

      return querySnapshot.docs
          .map((doc) => EntidadeMilitarModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Erro ao buscar Raps por título: $e");
    }
  }

  static Future<void> saveLote() async {
    const instituicao = [
      {
        "name": "Polícia Militar do Distrito Federal",
        "sigla": "PMDF",
        "description": "Instituição responsável pelo policiamento ostensivo e preservação da ordem pública no Distrito Federal.",
        "estado": "DF"
      },
      {
        "name": "Corpo de Bombeiros Militar do Distrito Federal",
        "sigla": "CBMDF",
        "description": "Atua na prevenção e combate a incêndios, salvamentos e defesa civil no DF.",
        "estado": "DF"
      },
      {
        "name": "Polícia Civil do Distrito Federal",
        "sigla": "PCDF",
        "description": "Responsável pelas investigações criminais e polícia judiciária no Distrito Federal.",
        "estado": "DF"
      },
      {
        "name": "Polícia Federal",
        "sigla": "PF",
        "description": "Polícia judiciária da União com sede em Brasília; atua no combate ao crime federal e na segurança das instituições.",
        "estado": "DF"
      },
      {
        "name": "Marinha do Brasil",
        "sigla": "MB",
        "description": "Ramo das Forças Armadas responsável pela defesa naval e segurança das águas territoriais brasileiras. Possui representações em Brasília.",
        "estado": "DF"
      },
      {
        "name": "Força Aérea Brasileira",
        "sigla": "FAB",
        "description": "Responsável pela defesa aérea do território nacional e gestão do espaço aéreo. Comando central em Brasília.",
        "estado": "DF"
      },
      {
        "name": "Exército Brasileiro",
        "sigla": "EB",
        "description": "Responsável pela defesa terrestre do país. Comando central em Brasília com diversas unidades subordinadas.",
        "estado": "DF"
      },
      {
        "name": "Polícia Penal do Distrito Federal",
        "sigla": "PPDF",
        "description": "Responsável pela segurança, custódia e administração do sistema penitenciário do Distrito Federal.",
        "estado": "DF"
      }
    ];

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection(collectionName);

    for (final item in instituicao) {
      await collection.add(item);
    }
  }
}