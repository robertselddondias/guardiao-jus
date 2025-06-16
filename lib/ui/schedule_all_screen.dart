import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/schedule_all_controller.dart';
import 'package:guardiao_cliente/enums/schedule_type.dart';
import 'package:guardiao_cliente/models/schedule_model.dart';
import 'package:guardiao_cliente/widgets/loading_indicator.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils/date_utils_custom.dart';

class ScheduleAllScreen extends StatelessWidget {
  const ScheduleAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleAllController controller = Get.put(ScheduleAllController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingIndicator();
        }

        return Column(
          children: [
            _buildCalendar(controller, theme),
            const Divider(height: 1),
            Expanded(child: _buildEventList(controller, theme)),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>  _showEditEventSheet(context, controller, isEditing: false),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditEventSheet(BuildContext context,
      ScheduleAllController controller, {required bool isEditing}) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 36,
              ),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: constraints.maxHeight * 0.9,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          height: 4,
                          width: MediaQuery.of(context).size.width * 0.2,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Text(
                        isEditing ? 'Editar Agendamento' : 'Adicionar Agendamento',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Exibição da Data (Fixada)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              DateUtilsCustom.formatDateToBrazil(controller.selectedDate.value),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Campo de Título
                      TextField(
                        controller: controller.titleController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Campo de Descrição
                      TextField(
                        controller: controller.descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Seleção de Horário
                      ListTile(
                        title: Text(
                          'Horário: ${controller.selectedTime.value.isEmpty ? "Selecionar" : controller.selectedTime.value}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        trailing: Icon(Icons.access_time, color: theme.colorScheme.primary),
                        onTap: () async {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime != null) {
                            controller.selectedTime.value = selectedTime.format(context);
                          }
                        },
                      ),
                      const SizedBox(height: 24),

                      // 🔹 Botões Responsivos
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (isEditing) {
                                  controller.updateSchedule();
                                } else {
                                  controller.addSchedule();
                                }
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(isEditing ? 'Atualizar' : 'Salvar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      controller.clearFormFields();
    });
  }

  /// 🔹 **Calendário Moderno**
  Widget _buildCalendar(ScheduleAllController controller, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime(2024),
            lastDay: DateTime(2030),
            focusedDay: controller.focusedDay.value,
            selectedDayPredicate: (day) =>
                isSameDay(controller.selectedDate.value, day),
            onDaySelected: (selectedDay, focusedDay) {
              controller.onDaySelected(selectedDay, focusedDay);
            },
            onPageChanged: (focusedDay) {
              controller.focusedDay.value = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, date, _) {
                final int eventCount = controller.schedules.where((event) {
                  return isSameDay(DateTime.parse(event.date), date);
                }).length;

                final bool hasEvents = eventCount > 0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.all(6),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hasEvents
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (hasEvents)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$eventCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 **Lista de Eventos**
  Widget _buildEventList(ScheduleAllController controller, ThemeData theme) {
    return Obx(() {
      final events = controller.schedules.where((schedule) {
        return DateFormat('yyyy-MM-dd').format(DateTime.parse(schedule.date)) ==
            DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
      }).toList();

      if (events.isEmpty) {
        return _buildEmptyState(theme, 'Nenhum evento para esta data.', Icons.event_busy);
      }

      return ListView.builder(
        itemCount: events.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final ScheduleModel event = events[index];
          return _buildEventCard(context, event, controller, theme);
        },
      );
    });
  }

  /// 🔹 **Cartão de Evento**
  Widget _buildEventCard(BuildContext context, ScheduleModel event, ScheduleAllController controller, ThemeData theme) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: event.scheduleType.color.withOpacity(0.2),
          child: Icon(event.scheduleType.icon, color: event.scheduleType.color, size: 28),
        ),
        title: Text(
          event.title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 4),
                Text(event.time, style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              event.description,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
        onTap: () => _showEventDetailsDialog(context, event),
      ),
    );
  }

  /// 🔹 **Estado vazio personalizado**
  Widget _buildEmptyState(ThemeData theme, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: theme.colorScheme.primary.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  void _showEventDetailsDialog(BuildContext context, ScheduleModel event) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom + 16, // 🔹 Ajusta para o teclado
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Barra Indicativa de Arrastar
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Ícone e Título do Agendamento
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: event.scheduleType.color.withOpacity(0.2),
                    child: Icon(event.scheduleType.icon,
                        color: event.scheduleType.color, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 Informações Detalhadas
              _buildDetailRow(theme, Icons.calendar_today, "Data",
                  DateUtilsCustom.formatDateStringToBrasilDateString(event.date)),
              _buildDetailRow(theme, Icons.access_time, "Horário", event.time),
              _buildDetailRow(
                  theme, Icons.description, "Descrição", event.description),
              _buildDetailRow(theme, Icons.category, "Tipo",
                  event.scheduleType.label),

              const SizedBox(height: 24),

              // 🔹 Botão Fechar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Fechar",
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onPrimary)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 🔹 **Método para Criar Linhas de Informações**
  Widget _buildDetailRow(ThemeData theme, IconData icon, String label,
      String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}