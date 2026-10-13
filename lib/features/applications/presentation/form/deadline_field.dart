import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/theme/icons.dart';
import '../../../../core/theme/tokens.dart';
import '../../../../core/time/deadline.dart';
import '../../domain/application_draft.dart';

/// Applies a change to the *current* value. Pickers await a dialog, so
/// changes are expressed as functions and applied to the latest form state
/// rather than to a value captured before the dialog opened.
typedef DeadlineUpdate = void Function(
  DeadlineInput Function(DeadlineInput current) change,
);

/// Date + time + time zone, with a live preview of the exact moment in the
/// viewer's own time. The zone is the one the university publishes in.
class DeadlineField extends StatelessWidget {
  const DeadlineField({
    super.key,
    required this.label,
    required this.value,
    required this.onUpdate,
    this.errorText,
  });

  final String label;
  final DeadlineInput value;
  final DeadlineUpdate onUpdate;
  final String? errorText;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value.date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      helpText: label,
    );
    if (picked != null) onUpdate((v) => v.copyWith(date: picked));
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: value.hour, minute: value.minute),
      helpText: 'Time in ${value.zone ?? 'the university’s zone'}',
    );
    if (picked != null) {
      onUpdate((v) => v.copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final gt = context.gt;
    final wide = MediaQuery.sizeOf(context).width >= GtBreakpoints.medium;
    final deadline = value.toDeadline();

    final date = _PickerBox(
      label: label,
      text: value.date == null
          ? null
          : DateFormat('EEE d MMM yyyy').format(value.date!),
      placeholder: 'No date yet',
      icon: GtIcons.thisWeek,
      onTap: () => _pickDate(context),
      onClear: value.date == null
          ? null
          : () => onUpdate((v) => v.copyWith(date: null)),
      errorText: value.date == null ? null : errorText,
    );
    final time = _PickerBox(
      label: 'Time',
      text:
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      icon: GtIcons.clock,
      onTap: value.date == null ? null : () => _pickTime(context),
    );
    final zone = TimezoneField(
      value: value.zone,
      at: deadline?.instant,
      enabled: value.date != null,
      onChanged: (z) => onUpdate((v) => v.copyWith(zone: z)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: date),
              const SizedBox(width: GtSpace.md),
              Expanded(flex: 2, child: time),
              const SizedBox(width: GtSpace.md),
              Expanded(flex: 5, child: zone),
            ],
          )
        else ...[
          date,
          const SizedBox(height: GtSpace.md),
          Row(
            children: [
              Expanded(flex: 2, child: time),
              const SizedBox(width: GtSpace.md),
              Expanded(flex: 5, child: zone),
            ],
          ),
        ],
        if (deadline != null) ...[
          const SizedBox(height: GtSpace.sm),
          Text(
            deadline.differsFromLocal
                ? '${deadline.zoneLabel} = ${deadline.localLabel} your time · ${DueText.relative(deadline.instant)}'
                : '${deadline.zoneLabel} · ${DueText.relative(deadline.instant)}',
            style: t.bodySmall?.copyWith(color: gt.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.label,
    required this.text,
    required this.icon,
    required this.onTap,
    this.placeholder,
    this.onClear,
    this.errorText,
  });

  final String label;
  final String? text;
  final String? placeholder;
  final GtGlyph icon;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    return Semantics(
      button: true,
      label: '$label: ${text ?? placeholder ?? ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GtRadius.md),
        child: InputDecorator(
          isEmpty: false,
          decoration: InputDecoration(
            labelText: label,
            enabled: onTap != null,
            errorText: errorText,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: GtSpace.md,
                right: GtSpace.sm,
              ),
              child: GtIcon(icon, size: GtIconSize.inline, color: gt.textMuted),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: onClear == null
                ? null
                : IconButton(
                    tooltip: 'Clear',
                    onPressed: onClear,
                    icon: GtIcon(GtIcons.close, size: 18, color: gt.textMuted),
                  ),
          ),
          child: Text(
            text ?? placeholder ?? '',
            style: TextStyle(color: text == null ? gt.textMuted : null),
          ),
        ),
      ),
    );
  }
}

/// Searchable IANA zone picker: "Toronto" finds America/Toronto.
class TimezoneField extends StatelessWidget {
  const TimezoneField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.at,
  });

  final String? value;

  /// Describe the zone's offset at this instant (e.g. the deadline), since
  /// daylight saving can differ from today. Defaults to now.
  final DateTime? at;
  final ValueChanged<String> onChanged;
  final bool enabled;

  static final List<String> _zones =
      tz.timeZoneDatabase.locations.keys
          .where((z) => z.contains('/') && !z.startsWith('Etc/'))
          .toList()
        ..add('UTC')
        ..sort();

  static String describe(String zone, [DateTime? at]) {
    final location = tz.getLocation(zone);
    final now = at == null
        ? tz.TZDateTime.now(location)
        : tz.TZDateTime.from(at, location);
    final offset = now.timeZoneOffset;
    final sign = offset.isNegative ? '−' : '+';
    final h = offset.inHours.abs();
    final m = offset.inMinutes.abs() % 60;
    final utc = 'UTC$sign$h${m == 0 ? '' : ':${m.toString().padLeft(2, '0')}'}';
    return '${now.timeZoneName} · $utc';
  }

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    return Autocomplete<String>(
      key: ValueKey(value),
      initialValue: TextEditingValue(text: value ?? ''),
      optionsBuilder: (text) {
        final q = text.text.trim().toLowerCase().replaceAll(' ', '_');
        if (q.isEmpty || q == value?.toLowerCase()) return _zones.take(50);
        return _zones.where((z) => z.toLowerCase().contains(q)).take(50);
      },
      onSelected: onChanged,
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            onSubmitted: (_) => onSubmitted(),
            decoration: InputDecoration(
              labelText: 'Time zone',
              hintText: 'Search a city, e.g. Toronto',
              helperText: value == null ? null : describe(value!, at),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: GtSpace.md,
                  right: GtSpace.sm,
                ),
                child: GtIcon(
                  GtIcons.globe,
                  size: GtIconSize.inline,
                  color: gt.textMuted,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
            ),
          ),
      optionsViewBuilder: (context, onSelected, options) =>
          _OptionsList<String>(
            options: options.toList(),
            onSelected: onSelected,
            title: (z) => z.replaceAll('_', ' '),
            subtitle: describe,
          ),
    );
  }
}

/// Dropdown panel styled like the app's cards, shared by autocompletes.
class _OptionsList<T extends Object> extends StatelessWidget {
  const _OptionsList({
    required this.options,
    required this.onSelected,
    required this.title,
    this.subtitle,
  });

  final List<T> options;
  final AutocompleteOnSelected<T> onSelected;
  final String Function(T) title;
  final String Function(T)? subtitle;

  @override
  Widget build(BuildContext context) => OptionsPanel<T>(
    options: options,
    onSelected: onSelected,
    itemBuilder: (context, o, highlighted) => ListTile(
      dense: true,
      selected: highlighted,
      title: Text(title(o)),
      subtitle: subtitle == null ? null : Text(subtitle!(o)),
    ),
  );
}

/// Card-styled options overlay with keyboard highlight support.
class OptionsPanel<T extends Object> extends StatelessWidget {
  const OptionsPanel({
    super.key,
    required this.options,
    required this.onSelected,
    required this.itemBuilder,
  });

  final List<T> options;
  final AutocompleteOnSelected<T> onSelected;
  final Widget Function(BuildContext context, T option, bool highlighted)
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    final gt = context.gt;
    final highlighted = AutocompleteHighlightedOption.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: gt.surface,
        elevation: 6,
        shadowColor: const Color(0x2206011A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GtRadius.md),
          side: BorderSide(color: gt.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280, maxWidth: 420),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: GtSpace.xs),
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, i) => InkWell(
              onTap: () => onSelected(options[i]),
              child: itemBuilder(context, options[i], i == highlighted),
            ),
          ),
        ),
      ),
    );
  }
}
