import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/company_model.dart';

class CompanyRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath = 'companies';

  /// Cria uma nova empresa na coleção.
  Future<void> createCompany(CompanyModel company) async {
    try {
      String docId = company.id ?? _firestore.collection(collectionPath).doc().id;
      company.id = docId;

      await _firestore.collection(collectionPath).doc(docId).set(company.toMap());
      print("Empresa criada com sucesso!");
    } catch (e) {
      throw Exception("Erro ao criar empresa: $e");
    }
  }

  /// Obtém uma empresa específica pelo ID.
  Future<CompanyModel?> getCompanyById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collectionPath).doc(id).get();
      if (doc.exists) {
        return CompanyModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Erro ao obter empresa: $e");
    }
  }

  /// Lista todas as empresas.
  Future<List<CompanyModel>> getAllCompanies() async {
    try {
      QuerySnapshot query = await _firestore.collection(collectionPath).get();

      return query.docs.map((doc) {
        return CompanyModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao listar empresas: $e");
    }
  }

  /// Atualiza os dados de uma empresa.
  Future<void> updateCompany(CompanyModel company) async {
    try {
      if (company.id == null) {
        throw Exception("ID da empresa é necessário para atualização.");
      }

      await _firestore.collection(collectionPath).doc(company.id).update(company.toMap());
      print("Empresa atualizada com sucesso!");
    } catch (e) {
      throw Exception("Erro ao atualizar empresa: $e");
    }
  }

  /// Remove uma empresa pelo ID.
  Future<void> deleteCompany(String id) async {
    try {
      await _firestore.collection(collectionPath).doc(id).delete();
      print("Empresa removida com sucesso!");
    } catch (e) {
      throw Exception("Erro ao remover empresa: $e");
    }
  }

  /// Pesquisa empresas pelo nome.
  Future<List<CompanyModel>> searchCompaniesByName(String name) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(collectionPath)
          .where('name', isGreaterThanOrEqualTo: name)
          .where('name', isLessThanOrEqualTo: '$name\uf8ff')
          .get();

      return query.docs.map((doc) {
        return CompanyModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw Exception("Erro ao pesquisar empresas: $e");
    }
  }
}
