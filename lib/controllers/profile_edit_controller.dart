
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/address_model.dart';
import 'package:guardiao_cliente/models/military_model.dart';
import 'package:guardiao_cliente/models/user_model.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ProfileEditController extends GetxController {

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Controladores dos campos de texto
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cpfController = TextEditingController();
  final birthDateController = TextEditingController();

  // Controladores de endereço
  final cepController = TextEditingController();
  final ufController = TextEditingController();
  final cityController = TextEditingController();
  final districtController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();

  // Controladores de dados militares
  final registrationNumberController = TextEditingController();
  final rankController = TextEditingController();
  final militaryUfController = TextEditingController();
  final entityController = TextEditingController();

  // Referência ao Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString userPhoto = ''.obs;

  final phoneMask = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')});

  @override
  void onInit() async {
    Future.delayed(Duration.zero, fetchUserData);
    super.onInit();
  }

  // Método para buscar os dados do usuário
  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user == null) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      final DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        SnackbarCustom.showError('Dados do usuário não encontrados.');
        return;
      }

      final userData = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      final addressData = AddressModel.fromMap(userData.address!.toMap());
      final militaryData = MilitaryModel.fromMap(userData.militarData!.toMap());

      // Preenche os controladores com os dados do usuário
      nameController.text = userData.name ?? '';
      emailController.text = userData.email ?? '';
      phoneController.text = phoneMask.maskText(userData.phone!);
      cpfController.text = userData.cpf ?? '';
      birthDateController.text = userData.birthDate != null
          ? DateUtilsCustom.formatDateToBrazil(userData.birthDate!)
          : '';
      userPhoto.value = userData.photoUrl ?? '';

      cepController.text = addressData.cep ?? '';
      ufController.text = addressData.uf ?? '';
      cityController.text = addressData.city ?? '';
      districtController.text = addressData.district ?? '';
      streetController.text = addressData.street ?? '';
      numberController.text = addressData.number ?? '';
      complementController.text = addressData.complement ?? '';

      registrationNumberController.text = militaryData.registrationNumber ?? '';
      rankController.text = militaryData.rank ?? '';
      militaryUfController.text = militaryData.militaryUf ?? '';
      entityController.text = militaryData.entity ?? '';
      update();
    } catch (e) {
      SnackbarCustom.showError('Erro ao buscar dados do usuário: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para salvar os dados no Firebase
  Future<void> saveProfile() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user == null) {
        SnackbarCustom.showError('Usuário não autenticado.');
        return;
      }

      final addressModel = AddressModel(
        cep: cepController.text,
        uf: ufController.text,
        city: cityController.text,
        district: districtController.text,
        street: streetController.text,
        number: numberController.text,
        complement: complementController.text,
      );

      final militaryModel = MilitaryModel(
        registrationNumber: registrationNumberController.text,
        rank: rankController.text,
        militaryUf: militaryUfController.text,
        entity: entityController.text,
      );

      DocumentSnapshot userFirebase = await _firestore.collection('users').doc(user.uid).get();
      UserModel userModel = UserModel.fromMap(userFirebase.data() as Map<String, dynamic>);

      DateTime date = DateFormat("dd/MM/yyyy").parse(birthDateController.text);

      userModel.uid = user.uid;
      userModel.name = nameController.text;
      userModel.email = emailController.text;
      userModel.phone = phoneController.text;
      userModel.cpf = cpfController.text;
      userModel.birthDate = date;
      userModel.address = addressModel;
      userModel.photoUrl = userPhoto.value;
      userModel.militarData = militaryModel;

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap(), SetOptions(merge: true));
      Get.back();
      SnackbarCustom.showSuccess('Perfil atualizado com sucesso!');
    } catch (e) {
      SnackbarCustom.showError('Erro ao salvar perfil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Método para selecionar e atualizar a imagem de perfil
  Future<void> pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null || image.path.isEmpty) {
        SnackbarCustom.showInfo('Nenhuma imagem selecionada.');
        return;
      }

      final File file = File(image.path);

      // Salvar no Firebase Storage (exemplo)
      final user = _auth.currentUser;
      if (user != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg');

        final uploadTask = await storageRef.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Atualizar o URL no Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'photoUrl': downloadUrl,
        });
        userPhoto.value = downloadUrl;
        SnackbarCustom.showSuccess('Imagem de perfil atualizada com sucesso!');
        update();
      } else {
        SnackbarCustom.showError('Usuário não autenticado.');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao selecionar ou salvar imagem: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cpfController.dispose();
    birthDateController.dispose();
    cepController.dispose();
    ufController.dispose();
    cityController.dispose();
    districtController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    registrationNumberController.dispose();
    rankController.dispose();
    militaryUfController.dispose();
    entityController.dispose();
    super.dispose();
  }
}