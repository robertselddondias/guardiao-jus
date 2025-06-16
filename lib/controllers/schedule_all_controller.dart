import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/enums/schedule_type.dart';
import 'package:guardiao_cliente/repositories/scheduler_repository.dart';
import 'package:guardiao_cliente/utils/Preferences.dart';
import 'package:intl/intl.dart';

import '../models/schedule_model.dart';
import '../widgets/snackbar_custom.dart';

class ScheduleAllController extends GetxController {
  final ScheduleRepository _scheduleRepository = ScheduleRepository();

  // Observáveis
  RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;
  RxBool isLoading = false.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<DateTime> focusedDay = DateTime.now().obs;
  RxString selectedTime = ''.obs;
  String? editedScheduleId; // ID do agendamento em edição

  // Controladores de formulário
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // IDs
  late String userId;
  late String companyId;
  late String rapId;
  late String userAdvId;

  @override
  void onInit() async {
    userId = Preferences.getString('userId') ?? '';
    companyId = Preferences.getString('companyId') ?? '';
    fetchSchedulesByUserAndCompanyId();

    super.onInit();
  }

  // Buscar agendamentos por usuário e empresa
  Future<void> fetchSchedulesByUserAndCompanyId() async {
    try {
      isLoading.value = true;
      schedules.value = await _scheduleRepository.getSchedulesByUserId();
    } catch (e) {
      SnackbarCustom.showError('Erro ao carregar agendamentos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSchedulesForMonth(DateTime focusedDay) async {
    try {
      isLoading.value = true;
      final List<ScheduleModel> fetchedSchedules = await _scheduleRepository.getSchedules(
        month: focusedDay.month,
        year: focusedDay.year,
      );
      schedules.assignAll(fetchedSchedules);
    } catch (e) {
      print("Erro ao carregar agendamentos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    selectedDate.value = selectedDay;
    this.focusedDay.value = focusedDay;
    fetchSchedulesForMonth(focusedDay);
  }

  // Carregar agendamento para edição
  void loadScheduleForEditing(ScheduleModel schedule) {
    editedScheduleId = schedule.id;
    titleController.text = schedule.title;
    descriptionController.text = schedule.description;
    selectedTime.value = schedule.time;
    selectedDate.value = DateTime.parse(schedule.date);
  }

  // Adicionar novo agendamento
  Future<void> addSchedule() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedTime.isEmpty){
      SnackbarCustom.showInfo('Preencha todos os campos antes de salvar.');
      return;
    }

    try {
      String hours = selectedTime.value;

      final newSchedule = ScheduleModel(
        nomeCliente: Preferences.getString('userName'),
        createAt: DateTime.now().toIso8601String(),



        scheduleType: ScheduleType.INDIVIDUAL,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        time: hours,
        date: DateFormat('yyyy-MM-dd').format(selectedDate.value),
        userId: Preferences.getString('userId'),
        notified: false
      );
      await _scheduleRepository.addSchedule(newSchedule);

      SnackbarCustom.showSuccess('Agendamento adicionado com sucesso.');

       clearFormFields();
       fetchSchedulesByUserAndCompanyId();
    } catch (e) {
      SnackbarCustom.showError('Erro ao adicionar agendamento: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Atualizar agendamento existente
  Future<void> updateSchedule() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        selectedTime.isEmpty) {
      SnackbarCustom.showInfo('Preencha todos os campos antes de salvar.');
      return;
    }

    try {
      isLoading.value = true;
      final updatedSchedule = ScheduleModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        time: selectedTime.value,
        date: selectedDate.value.toIso8601String(),
        userId: Preferences.getString('userId'),
        scheduleType: ScheduleType.INDIVIDUAL,
        notified: false
      );
      await _scheduleRepository.updateSchedule(editedScheduleId!, updatedSchedule);
      SnackbarCustom.showSuccess('Agendamento atualizado com sucesso.');
      clearFormFields();
    } catch (e) {
      SnackbarCustom.showError('Erro ao atualizar agendamento: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Excluir agendamento
  Future<void> deleteSchedule(ScheduleModel schedule) async {
    try {
      isLoading.value = true;
      if(schedule.companyId == null) {
        await _scheduleRepository.deleteSchedule(schedule.id!);
        fetchSchedulesByUserAndCompanyId();
        SnackbarCustom.showSuccess('Agendamento excluído com sucesso.');
      } else {
        SnackbarCustom.showWarning('Você não pode excluir uma agendamento feito pelo jurídico.');
      }
    } catch (e) {
      SnackbarCustom.showError('Erro ao excluir agendamento: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Limpar campos do formulário
  void clearFormFields() {
    titleController.clear();
    descriptionController.clear();
    selectedTime.value = '';
    selectedDate.value = DateTime.now();
    editedScheduleId = null;
  }

}