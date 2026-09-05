import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cinemax_app/bloc/export.dart';

class ScheduleDialog {
  static void show(
    BuildContext context, {
    String? initialMovieTitle,
    String? initialCinema,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _ScheduleBottomSheet(
          initialMovieTitle: initialMovieTitle,
          initialCinema: initialCinema,
        );
      },
    );
  }
}

class _ScheduleBottomSheet extends StatefulWidget {
  final String? initialMovieTitle;
  final String? initialCinema;

  const _ScheduleBottomSheet({
    this.initialMovieTitle,
    this.initialCinema,
  });

  @override
  State<_ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<_ScheduleBottomSheet> {
  Timer? _clockTimer;
  bool _isManualTime = false;
  late DateTime _selectedTargetTime;
  String? _warningMessage;
  int _chosenLeadTime = 0;

  final List<String> _movieTitles = [
    'A New Hope',
    'The Empire Strikes Back',
    'Return of the Jedi',
    'The Phantom Menace',
    'Attack of the Clones',
    'Revenge of the Sith',
  ];

  final List<String> _cinemas = [
    'Grand Indonesia XXI',
    'Plaza Senayan XXI',
    'Senayan Park Cinepolis',
    'Central Park CGV Cinemas',
    'Mall Kelapa Gading XXI IMAX',
    'Kota Kasablanka XXI',
    'Metropole XXI',
  ];

  late String _chosenMovie;
  late String _chosenCinema;

  @override
  void initState() {
    super.initState();
    _selectedTargetTime = DateTime.now();

    _chosenMovie = widget.initialMovieTitle ?? _movieTitles.first;
    if (!_movieTitles.contains(_chosenMovie)) {
      _chosenMovie = _movieTitles.first;
    }

    _chosenCinema = widget.initialCinema ?? _cinemas.first;
    if (!_cinemas.contains(_chosenCinema)) {
      _chosenCinema = _cinemas.first;
    }

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isManualTime && mounted) {
        setState(() {
          _selectedTargetTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final targetDateTime = _selectedTargetTime;
    final triggerDateTime =
        targetDateTime.subtract(Duration(minutes: _chosenLeadTime));

    final currentMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final targetMinute = DateTime(targetDateTime.year, targetDateTime.month,
        targetDateTime.day, targetDateTime.hour, targetDateTime.minute);
    final triggerMinute = DateTime(triggerDateTime.year, triggerDateTime.month,
        triggerDateTime.day, triggerDateTime.hour, triggerDateTime.minute);

    final isTargetValid =
        !_isManualTime || !targetMinute.isBefore(currentMinute);
    final isTriggerValid =
        !_isManualTime || !triggerMinute.isBefore(currentMinute);

    String? dynamicWarning;
    if (!isTargetValid) {
      dynamicWarning = 'Showtime cannot be in the past.';
    } else if (!isTriggerValid) {
      final leadLabel = _chosenLeadTime > 0
          ? '$_chosenLeadTime minutes before showtime'
          : 'on time';
      final formattedNow = DateFormat('HH:mm:ss').format(now);
      dynamicWarning =
          'Alarm trigger time ($leadLabel) is already in the past compared to current time ($formattedNow). Reminder cannot be set for a past time.';
    }

    final activeWarning = _warningMessage ?? dynamicWarning;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Set Movie Reminder',
                style: TextStyle(
                  fontSize: AppDimens.titleMain,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepSlate,
                ),
              ),
              Semantics(
                button: true,
                label: 'Tutup dialog pengingat',
                child: Container(
                  width: AppDimens.buttonSize,
                  height: AppDimens.buttonSize,
                  alignment: Alignment.center,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close,
                        size: AppDimens.iconSize, color: AppColors.lightSlate),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.initialMovieTitle != null)
            TextFormField(
              initialValue: _chosenMovie,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Movie',
                labelStyle: const TextStyle(
                  color: AppColors.teal,
                  fontSize: AppDimens.captionSmall,
                ),
                fillColor: AppColors.surface,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primaryYellow, width: 2),
                ),
              ),
              style: const TextStyle(
                color: AppColors.deepSlate,
                fontWeight: FontWeight.w600,
                fontSize: AppDimens.textMain,
              ),
            )
          else
            DropdownButtonFormField<String>(
              initialValue: _chosenMovie,
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: 'Select Movie',
                labelStyle: const TextStyle(
                  color: AppColors.teal,
                  fontSize: AppDimens.captionSmall,
                ),
                fillColor: AppColors.surface,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.primaryYellow, width: 2),
                ),
              ),
              items: _movieTitles.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(
                    m,
                    style: const TextStyle(
                      color: AppColors.deepSlate,
                      fontSize: AppDimens.textMain,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _chosenMovie = val);
              },
            ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _chosenCinema,
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'Select Cinema',
              labelStyle: const TextStyle(
                color: AppColors.teal,
                fontSize: AppDimens.captionSmall,
              ),
              fillColor: AppColors.surface,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                      const BorderSide(color: AppColors.primaryYellow, width: 2),
              ),
            ),
            items: _cinemas.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(
                  c,
                  style: const TextStyle(
                    color: AppColors.deepSlate,
                    fontSize: AppDimens.textMain,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _chosenCinema = val);
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label:
                      'Pilih tanggal jadwal nonton: ${DateFormat("dd/MM/yyyy").format(_selectedTargetTime)}',
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepSlate,
                      side: const BorderSide(color: AppColors.border),
                      minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.calendar_today,
                        size: AppDimens.iconSize, color: AppColors.teal),
                    label: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedTargetTime),
                      style: const TextStyle(fontSize: AppDimens.textMain),
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedTargetTime.isBefore(now)
                            ? now
                            : _selectedTargetTime,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: now.add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setState(() {
                          _isManualTime = true;
                          _warningMessage = null;
                          _selectedTargetTime = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _selectedTargetTime.hour,
                            _selectedTargetTime.minute,
                            0,
                          );
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.buttonSpacing),
              Expanded(
                child: Semantics(
                  button: true,
                  label: !_isManualTime
                      ? 'Jam sekarang real-time: ${DateFormat("HH:mm").format(_selectedTargetTime)}. Ketuk untuk memilih jam manual.'
                      : 'Pilih jam jadwal nonton: ${DateFormat("HH:mm").format(_selectedTargetTime)}',
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.deepSlate,
                      side: BorderSide(
                        color: !_isManualTime
                            ? AppColors.teal
                            : AppColors.border,
                      ),
                      minimumSize: const Size.fromHeight(AppDimens.buttonHeight),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.access_time,
                        size: AppDimens.iconSize,
                        color: !_isManualTime
                            ? AppColors.darkTeal
                            : AppColors.teal),
                    label: Text(
                      DateFormat('HH:mm').format(_selectedTargetTime),
                      style: const TextStyle(fontSize: AppDimens.textMain),
                    ),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime:
                            TimeOfDay.fromDateTime(_selectedTargetTime),
                      );
                      if (picked != null) {
                        setState(() {
                          _isManualTime = true;
                          _warningMessage = null;
                          _selectedTargetTime = DateTime(
                            _selectedTargetTime.year,
                            _selectedTargetTime.month,
                            _selectedTargetTime.day,
                            picked.hour,
                            picked.minute,
                            0,
                          );
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          if (_isManualTime)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    setState(() {
                      _isManualTime = false;
                      _selectedTargetTime = DateTime.now();
                      _chosenLeadTime = 0;
                      _warningMessage = null;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync, size: 13, color: AppColors.teal),
                        SizedBox(width: 4),
                        Text(
                          'Sync with Real-Time Clock',
                          style: TextStyle(
                            fontSize: AppDimens.captionSmall,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),
          const Text(
            'REMINDER LEAD TIME',
            style: TextStyle(
              fontSize: AppDimens.captionSmall,
              fontWeight: FontWeight.bold,
              color: AppColors.teal,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _buildLeadTimeChip(
                  0,
                  'On time',
                  _chosenLeadTime,
                  (v) => setState(() {
                    _warningMessage = null;
                    _chosenLeadTime = v;
                  }),
                ),
                const SizedBox(width: AppDimens.buttonSpacing),
                _buildLeadTimeChip(
                  15,
                  '15m Before',
                  _chosenLeadTime,
                  (v) => setState(() {
                    _warningMessage = null;
                    _chosenLeadTime = v;
                  }),
                ),
                const SizedBox(width: AppDimens.buttonSpacing),
                _buildLeadTimeChip(
                  30,
                  '30m Before',
                  _chosenLeadTime,
                  (v) => setState(() {
                    _warningMessage = null;
                    _chosenLeadTime = v;
                  }),
                ),
                const SizedBox(width: AppDimens.buttonSpacing),
                _buildLeadTimeChip(
                  60,
                  '1h Before',
                  _chosenLeadTime,
                  (v) => setState(() {
                    _warningMessage = null;
                    _chosenLeadTime = v;
                  }),
                ),
                const SizedBox(width: AppDimens.buttonSpacing),
                _buildLeadTimeChip(
                  120,
                  '2h Before',
                  _chosenLeadTime,
                  (v) => setState(() {
                    _warningMessage = null;
                    _chosenLeadTime = v;
                  }),
                ),
              ],
            ),
          ),

          if (activeWarning != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withAlpha(90)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeWarning,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: AppDimens.captionSmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          Semantics(
            button: true,
            label: 'Simpan pengingat film',
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isTriggerValid
                    ? AppColors.primaryYellow
                    : const Color(0xFFCBD5E1),
                foregroundColor: AppColors.deepSlate,
                elevation: 0,
                minimumSize:
                    const Size.fromHeight(AppDimens.buttonHeightLarge),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final currentNow = DateTime.now();
                final finalTarget =
                    _isManualTime ? _selectedTargetTime : currentNow;
                final finalTrigger =
                    finalTarget.subtract(Duration(minutes: _chosenLeadTime));

                final currMin = DateTime(currentNow.year, currentNow.month,
                    currentNow.day, currentNow.hour, currentNow.minute);
                final finTargMin = DateTime(finalTarget.year, finalTarget.month,
                    finalTarget.day, finalTarget.hour, finalTarget.minute);
                final finTrigMin = DateTime(finalTrigger.year,
                    finalTrigger.month, finalTrigger.day, finalTrigger.hour, finalTrigger.minute);

                if (_isManualTime && finTargMin.isBefore(currMin)) {
                  setState(() {
                    _warningMessage = 'Showtime cannot be in the past.';
                  });
                  return;
                }

                if (_isManualTime && finTrigMin.isBefore(currMin)) {
                  setState(() {
                    final leadText = _chosenLeadTime > 0
                        ? '$_chosenLeadTime minutes before showtime'
                        : 'on time';
                    _warningMessage =
                        'Alarm trigger time ($leadText) is already in the past compared to current time (${DateFormat('HH:mm:ss').format(currentNow)}). Reminder cannot be scheduled for a past time.';
                  });
                  return;
                }

                final reminder = Reminder(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  movieId: 'sw_${_chosenMovie.hashCode}',
                  movieTitle: _chosenMovie,
                  cinemaName: _chosenCinema,
                  scheduledTime: finalTarget,
                  leadTimeMinutes: _chosenLeadTime,
                );
                context.read<ReminderBloc>().add(AddReminderEvent(reminder));
                ReminderProvider()
                    .showInstantConfirmation(_chosenMovie, _chosenCinema);
                Navigator.pop(context);
                final String leadText = _chosenLeadTime > 0
                    ? '$_chosenLeadTime minutes before showtime'
                    : 'on time';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primaryYellow,
                    content: Text(
                      'Reminder scheduled: $_chosenMovie at $_chosenCinema ($leadText)',
                      style: const TextStyle(
                        color: AppColors.deepSlate,
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimens.textMain,
                      ),
                    ),
                  ),
                );
              },
              child: const Text(
                'SAVE MOVIE REMINDER',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: AppDimens.textMain,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadTimeChip(
    int minutes,
    String label,
    int current,
    ValueChanged<int> onSelect,
  ) {
    final isSelected = current == minutes;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Pemberitahuan $label',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(minutes),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: AppDimens.buttonHeight,
          constraints: const BoxConstraints(minWidth: 104),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? AppColors.primaryYellow : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x20000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppDimens.captionSmall,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }
}
