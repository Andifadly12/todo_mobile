import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../data/api_ai_repository.dart';
import 'ask_ai_cubit.dart';

class AskAiPage extends StatelessWidget {
  const AskAiPage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => AskAiCubit(ApiAiRepository(context.read<ApiClient>())),
    child: const _AskView(),
  );
}

class _AskView extends StatefulWidget {
  const _AskView();
  @override
  State<_AskView> createState() => _AskViewState();
}

class _AskViewState extends State<_AskView> {
  final message = TextEditingController();
  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tanya AI')),
    body: SafeArea(
      child: BlocBuilder<AskAiCubit, AskAiState>(
        builder: (context, state) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    size: 42,
                    color: AppColors.brown,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ruang untuk ide baru.',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tanyakan ide, cara mengatur waktu, atau langkah untuk memulai. Setiap pertanyaan diproses secara mandiri.',
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: message,
                    enabled: !state.loading,
                    minLines: 3,
                    maxLines: 8,
                    maxLength: 4000,
                    decoration: const InputDecoration(
                      labelText: 'Pertanyaanmu',
                      hintText: 'Bagaimana membagi waktu belajar dan bekerja?',
                    ),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  PrimaryButton(
                    label: 'Tanyakan ke AI',
                    loading: state.loading,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      context.read<AskAiCubit>().ask(message.text);
                    },
                  ),
                  if (state.answer != null) ...[
                    const SizedBox(height: 28),
                    Text(
                      state.question!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SelectionArea(
                        child: Text(
                          state.answer!,
                          style: const TextStyle(height: 1.6),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
