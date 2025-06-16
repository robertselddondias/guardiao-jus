import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para salvar informações do usuário no Firestore
  Future<void> saveUserData(UserModel userModel) async {
    try {
      DocumentReference userRef;
      if(await existUserById()) {
        userModel.isFirstAccess = false;
        userRef = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      } else {
        userModel.isFirstAccess = true;
        userModel.isPersonalInfoComplete = false;
        userModel.isAdressInfoComplete = false;
        userModel.isMilitaryInfoComplete = false;
        userModel.isPlanoAtivo = false;
        userRef = _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);
      }
      await userRef.set(userModel.toMap(), SetOptions(merge: true));
      Preferences.setString('userId', userModel.uid!);
      if(userModel.companyId != null) {
        Preferences.setString('companyId', userModel.companyId!);
      }
    } catch (e) {
      throw Exception('Falha ao salvar informações do usuário: $e');
    }
  }

  Future<UserModel> getUserById() async {
    var user = await _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get();
    return UserModel.fromMap(user.data()!);
  }

  Future<bool> existUserById() async {
    var user = await _firestore.collection('users').doc(getCurrentUser()?.uid).get();
    return user.exists;
  }

  // Função para obter o usuário autenticado e convertê-lo em UserModel
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  // Função para login com Google
  Future<UserModel?> saveLoginInfo(UserCredential userCredential, User user) async {
    try{
      if(userCredential.additionalUserInfo!.isNewUser) {
        final userModel = UserModel.fromFirebaseUser(user);
        await saveUserData(userModel);
        return userModel;
            }
      return getUserById();
    } catch (e) {
      throw Exception('Falha ao fazer login com Google: $e');
    }
  }

  // Buscar usuários pelo `companyId` com filtros de nome e matrícula
  Future<List<UserModel>> fetchUsersByCompanyId({
    required String companyId,
    String? name,
    String? registration,
  }) async {
    try {
      Query query = _firestore.collection('users')
          .where('companyId', isEqualTo: companyId).orderBy('name', descending: false);

      if (name != null && name.isNotEmpty) {
        query = query.where('name', isGreaterThanOrEqualTo: name, isLessThan: '$name\uf8ff');
      }

      if (registration != null && registration.isNotEmpty) {
        query = query.where('militarData.registrationNumber', isEqualTo: registration);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar usuários: $e');
    }
  }
}