import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/ai_repository.dart';
import 'ai_cubit.dart';

class AiPromptSheet extends StatelessWidget {
  const AiPromptSheet({super.key, required this.repository});
  final AiRepository repository;
  @override
  Widget build(BuildContext context) =>
      BlocProvider(create: (_) => AiCubit(repository), child: const _Prompt());
}

class _Prompt extends StatefulWidget {
  const _Prompt();
  @override
  State<_Prompt> createState() => _PromptState();
}

class _PromptState extends State<_Prompt> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AiCubit, AiState>(
    listener: (context, state) {
      if (state.draft != null) Navigator.pop(context, state.draft);
    },
    builder: (context, state) => Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        8,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.brown),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ceritakan rencanamu.',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'AI membantu merapikannya menjadi draft tugas. Kamu bisa mengubah hasilnya sebelum menyimpan.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: text,
              enabled: !state.loading,
              maxLength: 1000,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Apa yang ingin kamu lakukan?',
                hintText: 'Contoh: Siapkan presentasi besok jam 9 pagi, prioritas tinggi.',
              ),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            PrimaryButton(
              label: state.loading ? 'Menyiapkan draft…' : 'Buat draft AI',
              loading: state.loading,
              onPressed: () => context.read<AiCubit>().generate(text.text),
            ),
          ],
        ),
      ),
    ),
  );
}
