import 'package:cloud_firestore/cloud_firestore.dart';

class EntidadeMilitaresService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Lista das entidades militares e policiais de Brasília (DF)
  final List<Map<String, dynamic>> entidades = [
    {
      "name": "Polícia Militar do Distrito Federal",
      "description": "Força policial responsável pelo policiamento ostensivo e preservação da ordem pública no DF.",
      "sigla": "PMDF",
      "estado": "DF"
    },
    {
      "name": "Corpo de Bombeiros Militar do Distrito Federal",
      "description": "Força de segurança especializada em prevenção e combate a incêndios, salvamentos e resgates.",
      "sigla": "CBMDF",
      "estado": "DF"
    },
    {
      "name": "Polícia Civil do Distrito Federal",
      "description": "Órgão de segurança pública responsável por investigar crimes e cumprir mandados judiciais.",
      "sigla": "PCDF",
      "estado": "DF"
    },
    {
      "name": "Departamento de Trânsito do Distrito Federal",
      "description": "Órgão responsável pelo controle e fiscalização do trânsito de veículos no DF.",
      "sigla": "DETRAN-DF",
      "estado": "DF"
    },
    {
      "name": "Polícia Federal - Superintendência no DF",
      "description": "Órgão de segurança pública responsável pela investigação de crimes federais e controle de fronteiras.",
      "sigla": "PF-DF",
      "estado": "DF"
    },
    {
      "name": "Guarda Municipal do Distrito Federal",
      "description": "Força municipal de segurança, responsável por proteger bens, serviços e instalações públicas.",
      "sigla": "GMDF",
      "estado": "DF"
    },
    {
      "name": "Força Nacional de Segurança Pública",
      "description": "Tropa federal de apoio à segurança pública em situações de crise.",
      "sigla": "FNSP",
      "estado": "DF"
    },
    {
      "name": "Departamento Penitenciário Nacional",
      "description": "Órgão responsável pela administração do sistema prisional federal.",
      "sigla": "DEPEN",
      "estado": "DF"
    },
    {
      "name": "Secretaria de Segurança Pública do Distrito Federal",
      "description": "Órgão do governo responsável pela coordenação das forças de segurança no DF.",
      "sigla": "SSP-DF",
      "estado": "DF"
    },
    {
      "name": "Batalhão de Operações Policiais Especiais",
      "description": "Unidade especializada da PMDF para operações de alta complexidade.",
      "sigla": "BOPE-PMDF",
      "estado": "DF"
    }
  ];

  // 🔹 Método para persistir a lista no Firestore
  Future<void> salvarEntidadesNoFirestore() async {
    CollectionReference entidadesRef = _firestore.collection("entidades_militares_policiais");

    for (var entidade in entidades) {
      await entidadesRef.add(entidade);
    }

    print("✅ Entidades cadastradas no Firestore com sucesso!");
  }
}