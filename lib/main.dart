import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';

import 'package:http/http.dart' as http;

import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'features/authentication/data/repositories/api_auth_repository.dart';
import 'features/authentication/domain/repositories/auth_repository.dart';
import 'features/authentication/presentation/pages/auth_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => RepositoryProvider<ApiClient>(
    create: (_) => ApiClient(baseUrl: ApiConfig.baseUrl, client: http.Client()),
    dispose: (client) => client.close(),
    child: RepositoryProvider<AuthRepository>(
      create: (context) => ApiAuthRepository(context.read<ApiClient>()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ruang • Authentication',
        theme: AppTheme.light,
        home: const AuthPage(),
      ),
    ),
  );
}
