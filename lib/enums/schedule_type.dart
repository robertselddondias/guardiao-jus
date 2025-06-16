import 'package:flutter/material.dart';

enum ScheduleType {
  INDIVIDUAL,
  RAP,
  PROCESSO,
  ADMINISTRATIVO,
}

extension ScheduleTypeExtension on ScheduleType {
  String get label {
    switch (this) {
      case ScheduleType.INDIVIDUAL:
        return "Pessoal";
      case ScheduleType.RAP:
        return "Agendamento RAP";
      case ScheduleType.PROCESSO:
        return "Agendamento Processo";
      case ScheduleType.ADMINISTRATIVO:
        return "Agendamento Proc. Administrativo";
    }
  }

  IconData get icon {
    switch (this) {
      case ScheduleType.INDIVIDUAL:
        return Icons.person_outline;
      case ScheduleType.RAP:
        return Icons.policy_outlined;
      case ScheduleType.PROCESSO:
        return Icons.balance_outlined;
      case ScheduleType.ADMINISTRATIVO:
        return Icons.assignment_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ScheduleType.INDIVIDUAL:
        return Colors.blueAccent;
      case ScheduleType.RAP:
        return Colors.deepPurpleAccent;
      case ScheduleType.PROCESSO:
        return Colors.green.shade700;
      case ScheduleType.ADMINISTRATIVO:
        return Colors.orange.shade700;
    }
  }
}