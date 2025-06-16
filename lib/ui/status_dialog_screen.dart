import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/ui/home_screen.dart';

class FullScreenStatusScreen extends StatelessWidget {
  final bool isSuccess; // Define se é sucesso (true) ou erro (false)
  final String message; // Mensagem personalizada

  const FullScreenStatusScreen({
    super.key,
    required this.isSuccess,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  size: screenSize.width * 0.3, // Ícone responsivo
                  color: Colors.white,
                ),
                SizedBox(height: screenSize.height * 0.03),
                Text(
                  isSuccess ? 'Sucesso' : 'Erro',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  message,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenSize.height * 0.05),
                ElevatedButton(
                  onPressed: () {
                    isSuccess ? Get.offAll(HomeScreen(), transition: Transition.upToDown) : Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: isSuccess ? Colors.green : Colors.red,
                    padding: EdgeInsets.symmetric(
                      vertical: screenSize.height * 0.02,
                      horizontal: screenSize.width * 0.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Voltar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
