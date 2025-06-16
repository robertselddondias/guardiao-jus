import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:guardiao_cliente/repositories/user_repository.dart';
import 'package:guardiao_cliente/widgets/snackbar_custom.dart';
import 'package:guardiao_cliente/ui/otp_screen.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:guardiao_cliente/utils/strategy_load_screen.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();

  final Rx<TextEditingController> phoneController = TextEditingController().obs;

  var maskFormatterCelular = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  RxBool isLoading = false.obs; // Controle de estado de carregamento
  var phoneNumber = ''.obs; // Controle de número de telefone
  RxString countryCode = "+55".obs;

  var verificationId = ''.obs;

  @override
  void onInit() async {
    super.onInit();

    await Preferences.clearSharPreference();
  }

  // Método para atualizar o código do país
  void updateCountryCode(String code) {
    countryCode.value = code;
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        SnackbarCustom.showError('Login com Google cancelado pelo usuário.');
        return; // Login cancelado pelo usuário
      }

      // Pegar as informações de perfil do usuário Google
      final String? displayName = googleUser.displayName;
      final String email = googleUser.email;
      final String? photoUrl = googleUser.photoUrl;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        SnackbarCustom.showError('Falha ao obter as credenciais do Google.');
        return;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      // Atualizar as informações do perfil se necessário
      if (user != null) {
        await updateUserProfile(user, displayName: displayName, photoUrl: photoUrl, email: email);
      }

      var userLogin = await _userRepository.saveLoginInfo(userCredential, user!);

      if (userLogin != null) {
        isLoading.value = false;
        Preferences.setString('userId', userLogin.uid!);
        // Salvar os dados extras
        if (displayName != null) Preferences.setString('displayName', displayName);
        Preferences.setString('email', email);
        if (photoUrl != null) Preferences.setString('photoUrl', photoUrl);

        if(userLogin.companyId != null) {
          Preferences.setString('companyId', userLogin.companyId!);
        }
        StrategyLoadScreen.validateAccess();
      } else {
        SnackbarCustom.showError('Usuário não encontrado após login com Google.');
        isLoading.value = false;
      }
    } on FirebaseAuthException catch (e) {
      // Tratamento de erros específicos do Firebase
      switch (e.code) {
        case 'account-exists-with-different-credential':
          SnackbarCustom.showError(
              'A conta já existe com um método de login diferente.');
          break;
        case 'invalid-credential':
          SnackbarCustom.showError('As credenciais fornecidas são inválidas.');
          break;
        case 'user-disabled':
          SnackbarCustom.showError('O usuário associado a essa conta foi desativado.');
          break;
        case 'operation-not-allowed':
          SnackbarCustom.showError('Operação de login com Google não está habilitada.');
          break;
        case 'network-request-failed':
          SnackbarCustom.showError('Falha na conexão com a internet.');
          break;
        default:
          SnackbarCustom.showError('Erro desconhecido: ${e.message}');
      }
    } on GoogleSignInAccount catch (e) {
      // Tratamento de erros específicos do Google SignIn
      SnackbarCustom.showError('Erro ao autenticar com Google: ${e.toString()}');
    } catch (e) {
      // Tratamento de erros genéricos
      SnackbarCustom.showError('Erro inesperado: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loginWithPhone() async {
    try {
      isLoading.value = true;

      phoneNumber.value = maskFormatterCelular.unmaskText(phoneController.value.text);

      const maximumAttemptTime = Duration(minutes: 2);

      await _auth.verifyPhoneNumber(

        phoneNumber: '${countryCode.value}${phoneNumber.value}',
        timeout: maximumAttemptTime,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.signInWithCredential(credential);
            SnackbarCustom.showSuccess('Autenticação concluída com sucesso!');
          } catch (e) {
            SnackbarCustom.showError('Erro ao autenticar: $e');
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          SnackbarCustom.showError('Falha na verificação: ${error.message}');
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          Get.to(() => const OtpScreen(),
            arguments: {'verificationId': verificationId, 'countryCode': countryCode.value, 'phoneNumber': phoneNumber.value},
          );
          isLoading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          isLoading.value = true;
          this.verificationId.value = verificationId;
          SnackbarCustom.showInfo('Tempo de recuperação do código expirado.');
        },
      );
    } catch (e) {
      SnackbarCustom.showError('Erro inesperado: $e');
      isLoading.value = false;
    }
  }

  /// Gera um nome baseado no email para casos onde o nome não está disponível no Apple Sign In
  String generateNameFromEmail(String email) {
    if (email.isEmpty) return "Usuário";
    return email.split('@')[0];
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Extrair informações do usuário
      final String? email = appleCredential.email;
      String? displayName;

      // Tentar obter o nome completo
      if (appleCredential.givenName != null && appleCredential.familyName != null) {
        displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
      } else if (appleCredential.givenName != null) {
        displayName = appleCredential.givenName;
      } else if (email != null) {
        // Se não tem nome, gerar um a partir do email
        displayName = generateNameFromEmail(email);
      }

      // Criar credenciais OAuth para o Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // Fazer login com Firebase Auth
      final userCredential = await _auth.signInWithCredential(oauthCredential);
      final User? user = userCredential.user;

      // Gerar URL de avatar baseado no email para Apple Sign In (usando Gravatar)
      String? photoUrl;
      if (email != null) {
        final emailTrim = email.trim().toLowerCase();
        final emailHash = md5.convert(utf8.encode(emailTrim)).toString();
        photoUrl = 'https://www.gravatar.com/avatar/$emailHash?d=identicon';
      }

      // Atualizar as informações do perfil se necessário
      if (user != null) {
        await updateUserProfile(user, displayName: displayName, photoUrl: photoUrl, email: email);
      }

      var userLogin = await _userRepository.saveLoginInfo(userCredential, user!);

      if (userLogin != null) {
        isLoading.value = false;
        Preferences.setString('userId', userLogin.uid!);
        // Salvar os dados extras
        if (displayName != null) Preferences.setString('displayName', displayName);
        if (email != null) Preferences.setString('email', email);
        if (photoUrl != null) Preferences.setString('photoUrl', photoUrl);

        if(userLogin.companyId != null) {
          Preferences.setString('companyId', userLogin.companyId!);
        }
        StrategyLoadScreen.validateAccess();
      } else {
        SnackbarCustom.showError('Usuário não encontrado após login com Apple.');
        isLoading.value = false;
      }
    } on FirebaseAuthException catch (e) {
      // Tratar erros específicos do Firebase
      switch (e.code) {
        case 'account-exists-with-different-credential':
          SnackbarCustom.showError('A conta já existe com outro método de login.');
          break;
        case 'invalid-credential':
          SnackbarCustom.showError('As credenciais da Apple são inválidas.');
          break;
        case 'user-disabled':
          SnackbarCustom.showError('Este usuário foi desativado.');
          break;
        case 'operation-not-allowed':
          SnackbarCustom.showError('Login com Apple não está habilitado.');
          break;
        default:
          SnackbarCustom.showError('Erro inesperado: ${e.message}');
          _auth.signOut();
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // Tratar erros específicos do Sign in with Apple
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          SnackbarCustom.showError('Login cancelado pelo usuário.');
          break;
        case AuthorizationErrorCode.failed:
          SnackbarCustom.showError('Falha no login com Apple.');
          break;
        case AuthorizationErrorCode.invalidResponse:
          SnackbarCustom.showError('Resposta inválida da Apple.');
          break;
        case AuthorizationErrorCode.notHandled:
          SnackbarCustom.showError('Requisição de login não processada.');
          break;
        case AuthorizationErrorCode.unknown:
          SnackbarCustom.showError('Erro desconhecido durante o login com Apple.');
          break;
        default:
          SnackbarCustom.showError('Erro inesperado: ${e.code}');
          _auth.signOut();
      }
    } catch (e) {
      // Tratar outros erros
      SnackbarCustom.showError('Erro inesperado: $e');
      _auth.signOut();
    } finally {
      isLoading.value = false;
    }
  }

  // Método para atualizar o perfil do usuário no Firebase
  Future<void> updateUserProfile(User user, {String? displayName, String? photoUrl, String? email}) async {
    try {
      // Só atualiza se algum dado for fornecido e diferente do atual
      if (displayName != null && displayName != user.displayName) {
        await user.updateDisplayName(displayName);
      }

      if (photoUrl != null && photoUrl != user.photoURL) {
        await user.updatePhotoURL(photoUrl);
      }

      // O email só pode ser atualizado se o usuário não tiver um email verificado
      if (email != null && email != user.email && !user.emailVerified) {
        await user.updateEmail(email);
      }
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      // Não lançamos erro para não interromper o fluxo de login
    }
  }

  Future<void> goToTermsAndConditions() async {
    Uri uri = Uri.parse('https://guardiaojus.com.br/termos');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir a URL';
    }
  }

  Future<void> goToPrivacidade() async {
    Uri uri = Uri.parse('https://guardiaojus.com.br/privacidade');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Não foi possível abrir a URL';
    }
  }
}