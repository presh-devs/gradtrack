import 'package:flutter/material.dart';

import '../../../core/theme/icons.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/gt_widgets.dart';

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

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
              PageHeader(title: 'People', subtitle: 'Professors and recommenders'),
              EmptyState(
                icon: GtIcons.people,
                title: 'Coming soon',
                message: 'Professor outreach, follow-ups and recommender tracking arrive in week 3.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
