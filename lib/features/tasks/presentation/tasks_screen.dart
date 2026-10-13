import 'package:flutter/material.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/gt_widgets.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.sizeOf(context).width < GtBreakpoints.medium ? GtSpace.lg : GtSpace.xxl;
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: pad),
      children: const [
        PageBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(title: 'Tasks', subtitle: 'Everything else on your plate'),
              EmptyState(
                icon: GtIcons.tasks,
                title: 'Coming soon',
                message: 'Standalone tasks arrive in week 3. Requirements and letters already show on Today.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
