import 'package:aurora_glass/src/kit/buttons.dart';
import 'package:aurora_glass/src/kit/sheet_insets.dart';
import 'package:aurora_glass/src/kit/signals.dart';
import 'package:aurora_glass/src/kit/surfaces.dart';
import 'package:aurora_glass/src/theme/tokens.dart';
import 'package:flutter/material.dart';

/// One choice in a [SelectionSheet].
// ignore: avoid-function-type-in-records
typedef SelectionOption = ({String label, bool selected, VoidCallback onSelect});

/// A modal bottom sheet of [ListRow]s: the one way to pick from a short list.
///
/// A vertical sheet shows every option at any text scale, and [ListRow] already marks a selection.
abstract final class SelectionSheet {
  /// Shows the sheet. Selecting an option applies it and closes the sheet.
  ///
  /// [tone] paints every option as that tone, so a destructive confirm looks destructive.
  /// [cancelLabel] adds an explicit way out for a user who does not know that dragging the sheet
  /// down is the cancel.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<SelectionOption> options,
    AppTone? tone,
    String? cancelLabel,
  }) => showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    // The insets go inside the scroll view, so the viewport keeps the sheet's width and the
    // keyboard moves the content rather than shortening the scroll region.
    builder: (sheetContext) => SingleChildScrollView(
      padding: SheetInsets.of(sheetContext),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: <Widget>[
          SectionLabel(title),
          const SizedBox(height: AppSpacing.xs),
          for (final option in options) ...<Widget>[
            ListRow(
              title: option.label,
              selected: option.selected,
              tone: tone,
              onTap: () {
                option.onSelect();
                Navigator.of(sheetContext).pop();
              },
            ),
            const SizedBox(height: 6),
          ],
          if (cancelLabel case final String label)
            Center(
              child: TextAction(label: label, onPressed: () => Navigator.of(sheetContext).pop()),
            ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    ),
  );
}
