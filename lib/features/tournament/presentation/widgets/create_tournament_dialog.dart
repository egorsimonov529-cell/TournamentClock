import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tournament_model.dart';
import '../../domain/providers/tournament_provider.dart';

class CreateTournamentDialog extends ConsumerStatefulWidget {
  final Tournament? tournament;

  const CreateTournamentDialog({super.key, this.tournament});

  @override
  ConsumerState<CreateTournamentDialog> createState() =>
      _CreateTournamentDialogState();
}

class _CreateTournamentDialogState
    extends ConsumerState<CreateTournamentDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxPlayersController;
  late TextEditingController _buyInController;
  late TextEditingController _formatController;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _startTime = const TimeOfDay(hour: 19, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);
  String _status = 'upcoming';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.tournament?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.tournament?.description ?? '',
    );
    _maxPlayersController = TextEditingController(
      text: widget.tournament?.maxPlayers.toString() ?? '100',
    );
    _buyInController = TextEditingController(
      text: widget.tournament?.buyIn.toString() ?? '0',
    );
    _formatController = TextEditingController(
      text: widget.tournament?.format ?? 'TT No-Limit',
    );
    _status = widget.tournament?.status ?? 'upcoming';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxPlayersController.dispose();
    _buyInController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _startDate = date);
      // После выбора даты сразу выбираем время
      await _selectStartTime();
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _endDate = date);
      // После выбора даты сразу выбираем время
      await _selectEndTime();
    }
  }

  Future<void> _selectStartTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (time != null) {
      setState(() => _startTime = time);
      // После выбора времени обновляем _startDate, сохраняя выбранную дату
      _startDate = DateTime(
        _startDate.year,
        _startDate.month,
        _startDate.day,
        _startTime.hour,
        _startTime.minute,
      );
    }
  }

  Future<void> _selectEndTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (time != null) {
      setState(() => _endTime = time);
      // После выбора времени обновляем _endDate, сохраняя выбранную дату
      _endDate = DateTime(
        _endDate.year,
        _endDate.month,
        _endDate.day,
        _endTime.hour,
        _endTime.minute,
      );
    }
  }

  void _save() {
    // Простая валидация без Form
    final name = _nameController.text.trim();
    final maxPlayers = int.tryParse(_maxPlayersController.text);

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название турнира')));
      return;
    }

    if (maxPlayers == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректное количество игроков')),
      );
      return;
    }

    final tournament = Tournament(
      id:
          widget.tournament?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      maxPlayers: maxPlayers,
      buyIn: double.tryParse(_buyInController.text) ?? 0,
      format: _formatController.text.trim(),
      status: _status,
      registeredPlayerIds: widget.tournament?.registeredPlayerIds ?? [],
    );

    if (widget.tournament != null) {
      ref.read(tournamentProvider.notifier).updateTournament(tournament);
    } else {
      ref.read(tournamentProvider.notifier).addTournament(tournament);
    }

    Navigator.pop(context);

    // Показываем успех
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.tournament != null
              ? 'Турнир обновлен'
              : 'Турнир создан: $name',
        ),
        backgroundColor: const Color(0xFF1ABC9C),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xff1D232C),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.tournament != null
                  ? 'Редактировать турнир'
                  : 'Создать турнир',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Название турнира',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xff0A0E14),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Описание',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xff0A0E14),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff0A0E14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff2A2D35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Начало: ${_startDate.day.toString().padLeft(2, '0')}.${_startDate.month.toString().padLeft(2, '0')}.${_startDate.year}  ${_startTime.format(context)}',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff0A0E14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xff2A2D35)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Окончание: ${_endDate.day.toString().padLeft(2, '0')}.${_endDate.month.toString().padLeft(2, '0')}.${_endDate.year}  ${_endTime.format(context)}',
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Max players and buy-in
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _maxPlayersController,
                    decoration: const InputDecoration(
                      labelText: 'Макс. игроков',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xff0A0E14),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _buyInController,
                    decoration: const InputDecoration(
                      labelText: 'Взнос (₽)',
                      labelStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xff0A0E14),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Format
            TextFormField(
              controller: _formatController,
              decoration: const InputDecoration(
                labelText: 'Формат',
                labelStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Color(0xff0A0E14),
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.tournament != null ? 'Сохранить' : 'Создать',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
