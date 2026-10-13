import 'package:flutter/widgets.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// A glyph from one of the Innixx icon sources. Iconsax ships as a font
/// ([IconData]); Hugeicons ships as SVG path data drawn by [HugeIcon].
/// Streamline has no Flutter package — export its SVGs from Figma into
/// assets/icons/ if one is ever needed and add an `_SvgGlyph` case here.
sealed class GtGlyph {
  const GtGlyph();
}

final class _Ix extends GtGlyph {
  const _Ix(this.data);
  final IconData data;
}

final class _Huge extends GtGlyph {
  const _Huge(this.data);
  final List<List<dynamic>> data;
}

/// Renders a [GtGlyph]; defaults to the ambient [IconTheme] like [Icon].
class GtIcon extends StatelessWidget {
  const GtIcon(this.glyph, {super.key, this.size, this.color, this.semanticLabel});

  final GtGlyph glyph;
  final double? size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? GtIconSize.nav;
    final c = color ?? theme.color;
    return switch (glyph) {
      _Ix(:final data) => Icon(data, size: s, color: c, semanticLabel: semanticLabel),
      _Huge(:final data) => Semantics(
          label: semanticLabel,
          excludeSemantics: semanticLabel == null,
          child: HugeIcon(icon: data, size: s, color: c, strokeWidth: 1.5),
        ),
    };
  }
}

/// App iconography, matching the Innixx v3 "Iconography" board (Figma node
/// 19:754 — sources: Iconsax, Hugeicons, Streamline). Iconsax is the primary
/// set (linear 24 px; bold for selected states); Hugeicons is used where the
/// board uses it (send, search, delete, close, link, user, more).
///
/// Screens use these semantic names, never a library directly, so the icon
/// set can be swapped or re-mapped in one place.
abstract final class GtIcons {
  // Navigation (linear / bold pairs)
  static const today = _Ix(IconsaxPlusLinear.sun_1);
  static const todaySelected = _Ix(IconsaxPlusBold.sun_1);
  static const applications = _Ix(IconsaxPlusLinear.teacher);
  static const applicationsSelected = _Ix(IconsaxPlusBold.teacher);
  static const people = _Ix(IconsaxPlusLinear.profile_2user);
  static const peopleSelected = _Ix(IconsaxPlusBold.profile_2user);
  static const tasks = _Ix(IconsaxPlusLinear.task_square);
  static const tasksSelected = _Ix(IconsaxPlusBold.task_square);
  static const settings = _Ix(IconsaxPlusLinear.setting_2);
  static const settingsSelected = _Ix(IconsaxPlusBold.setting_2);

  // Brand mark
  static const brand = _Ix(IconsaxPlusBold.teacher);

  // Attention item types
  static const deadline = _Ix(IconsaxPlusLinear.flag);
  static const funding = _Ix(IconsaxPlusLinear.wallet_money);
  static const requirement = _Ix(IconsaxPlusLinear.document_text);
  static const letter = _Ix(IconsaxPlusLinear.sms_tracking);
  static const followUp = _Huge(HugeIcons.strokeRoundedSent);
  static const task = _Ix(IconsaxPlusLinear.tick_circle);

  // Status & feedback
  static const overdue = _Ix(IconsaxPlusLinear.danger);
  static const thisWeek = _Ix(IconsaxPlusLinear.calendar_1);
  static const checklist = _Ix(IconsaxPlusLinear.task_square);
  static const info = _Ix(IconsaxPlusLinear.info_circle);
  static const error = _Ix(IconsaxPlusLinear.warning_2);
  static const offline = _Ix(IconsaxPlusLinear.cloud_cross);
  static const notFound = _Ix(IconsaxPlusLinear.search_status);
  static const allClear = _Ix(IconsaxPlusLinear.emoji_happy);
  static const topChoice = _Ix(IconsaxPlusBold.star_1);
  static const emailSent = _Ix(IconsaxPlusLinear.sms_tracking);
  static const digest = _Ix(IconsaxPlusLinear.notification_bing);

  // Actions
  static const add = _Ix(IconsaxPlusLinear.add);
  static const import = _Ix(IconsaxPlusLinear.document_upload);
  static const refresh = _Ix(IconsaxPlusLinear.refresh);
  static const back = _Ix(IconsaxPlusLinear.arrow_left_2);
  static const chevronRight = _Ix(IconsaxPlusLinear.arrow_right_3);
  static const chevronDown = _Ix(IconsaxPlusLinear.arrow_down_1);
  static const signOut = _Ix(IconsaxPlusLinear.logout);
  static const search = _Huge(HugeIcons.strokeRoundedSearch01);
  static const delete = _Huge(HugeIcons.strokeRoundedDelete02);
  static const close = _Huge(HugeIcons.strokeRoundedCancel01);
  static const link = _Huge(HugeIcons.strokeRoundedLink02);
  static const user = _Huge(HugeIcons.strokeRoundedUser03);
  static const more = _Huge(HugeIcons.strokeRoundedMoreHorizontal);

  // Form fields
  static const clock = _Ix(IconsaxPlusLinear.clock);
  static const globe = _Ix(IconsaxPlusLinear.global);
  static const university = _Ix(IconsaxPlusLinear.building_4);
  static const edit = _Ix(IconsaxPlusLinear.edit_2);
  static const money = _Ix(IconsaxPlusLinear.money_2);
  static const note = _Ix(IconsaxPlusLinear.note_1);

  // Theme
  static const themeSystem = _Ix(IconsaxPlusLinear.monitor);
  static const themeLight = _Ix(IconsaxPlusLinear.sun_1);
  static const themeDark = _Ix(IconsaxPlusLinear.moon);
}

/// Iconsax glyphs sit slightly lighter than Material's at the same size; use
/// 20 px inline and 24 px for navigation, as on the Innixx board.
abstract final class GtIconSize {
  static const inline = 20.0;
  static const nav = 24.0;
}
