import 'package:flutter/material.dart';

import '../../../core/widgets/organisms/app_footer.dart';
import '../../profile/presentation/profile_page.dart';
import '../../todos/presentation/todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Preserve the existing post-authentication destination: Profile.
  int index = 1;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: index,
      children: const [TodoPage(), ProfilePage()],
    ),
    bottomNavigationBar: AppFooter(
      index: index,
      onSelected: (value) => setState(() => index = value),
    ),
  );
}
