import 'package:flutter/widgets.dart';
import '../../../core/theme/theme.dart';
import '../../../ui/components/zen_scaffold.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.zenTheme;
    return ZenScaffold(
      child: Center(
        child: Text(
          'Your entries will appear here.',
          style: theme.text.bodyMedium.copyWith(
            color: theme.colors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}
