import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/models/note_model.dart';
import 'package:guardiao_cliente/utils/date_utils_custom.dart';

class GuardiaoWidget {

  /// 🔹 **Título das Seções**
  static Widget buildSectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// 🔹 **Seção de Notas - Agora com um Acordeão Estilizado**
  static Widget buildNotesSection(List<NoteModel> notas, ThemeData theme) {
    return Obx(() {
      if (notas.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          iconColor: theme.colorScheme.primary,
          collapsedIconColor: theme.colorScheme.primary,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          title: Row(
            children: [
              Icon(Icons.notes, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Notas do Processo",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: notas.map((nota) => _buildNoteItem(nota, theme)).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// 🔹 **Nota Individual (Design Moderno)**
  static Widget _buildNoteItem(NoteModel nota, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showNoteDetailsDialog(Get.context!, nota),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.note, color: theme.colorScheme.secondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nota.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nota.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      DateUtilsCustom.formatDate(nota.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Diálogo Moderno para Exibir Nota**
  static void _showNoteDetailsDialog(BuildContext context, NoteModel nota) {
    final theme = Theme.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 5,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.sticky_note_2_outlined, color: theme.colorScheme.primary, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          nota.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(thickness: 1, height: 20),

                  // 🔹 Data de Criação
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    nota.createdAt == null
                        ? 'Data não disponível'
                        : 'Criado em ${DateUtilsCustom.formatDate(nota.createdAt)}',
                    theme,
                  ),
                  const SizedBox(height: 12),

                  // 🔹 Descrição da Nota com Ícone e Alinhamento Corrigido
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description_outlined, color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              nota.description.isNotEmpty ? nota.description : 'Nenhuma descrição disponível.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.9),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.left, // Mantendo alinhado à esquerda
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🔹 **Linha de Informações com Ícone**
  static Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildArquivos(BuildContext context, {
    required String title,
    VoidCallback? onAddPressed,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        iconColor: theme.colorScheme.primary,
        collapsedIconColor: theme.colorScheme.primary,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (onAddPressed != null)
              GestureDetector(
                onTap: onAddPressed,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: child,
          ),
        ],
      ),
    );
  }

  static Widget buildInputField(BuildContext context, {
    required String label,
    required String hint,
    required TextEditingController controller,
    required ThemeData theme,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isDate = false,
    required TextCapitalization textCapitalization,
    dynamic mask,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '$label *',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            autocorrect: true,
            enableSuggestions: true,
            textCapitalization: textCapitalization,
            inputFormatters: mask != null ? [mask] : [],
            readOnly: isDate,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
              prefixIcon: Icon(prefixIcon, color: theme.colorScheme.primary.withOpacity(0.7)),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
              ),
            ),
            onTap: isDate
                ? () async {
              FocusScope.of(context).unfocus();
              DateTime? pickedDate = await showDatePicker(
                context: Get.context!,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: theme.colorScheme.primary,
                        onPrimary: theme.colorScheme.onPrimary,
                        surface: theme.colorScheme.surface,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                controller.text = DateUtilsCustom.formatDateToBrazil(pickedDate);
              }
            }
                : null,
          ),
        ],
      ),
    );
  }
}

