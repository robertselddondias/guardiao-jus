import 'package:flutter/material.dart';

enum PedidoType {
  PROCESSO,
  PROCEDIMENTO_ADMINISTRATIVO,
}

extension PedidoTypeExtension on PedidoType {
  String get label {
    switch (this) {
      case PedidoType.PROCESSO:
        return 'Processo';
      case PedidoType.PROCEDIMENTO_ADMINISTRATIVO:
        return 'Procedimento Administrativo';
    }
  }

  String get description {
    switch (this) {
      case PedidoType.PROCESSO:
        return 'Gerencie seus processos judiciais.';
      case PedidoType.PROCEDIMENTO_ADMINISTRATIVO:
        return 'Acesse os registros do Procedimento Administrativo.';
    }
  }

  IconData get icon {
    switch (this) {
      case PedidoType.PROCESSO:
        return Icons.balance_outlined;
      case PedidoType.PROCEDIMENTO_ADMINISTRATIVO:
        return Icons.folder_open_outlined;
    }
  }

  Color get color {
    switch (this) {
      case PedidoType.PROCESSO:
        return const Color(0xFF81D4FA); // Azul pastel
      case PedidoType.PROCEDIMENTO_ADMINISTRATIVO:
        return const Color(0xFFA5D6A7); // Verde pastel
    }
  }
}