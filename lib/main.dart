import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/data/datasources/auth_remote_datasource.dart';
import 'login/data/repositories/auth_repository_impl.dart';
import 'login/domain/usecases/login_usecase.dart';
import 'login/presentation/blocs/auth_bloc.dart';
import 'login/presentation/pages/login_page.dart';
import 'home/data/datasources/residential_remote_datasource.dart';
import 'home/data/repositories/residential_repository_impl.dart';
import 'home/presentation/blocs/residential_bloc.dart';
import 'home/presentation/pages/admin_page.dart';
import 'core/storage/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String? token = await Storage.getToken();

  runApp(MyApp(isAuthenticated: token != null));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  MyApp({required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            LoginUseCase(
              AuthRepositoryImpl(AuthRemoteDataSource()),
            ),
          ),
        ),
        BlocProvider<ResidentialBloc>(
          create: (context) {
            final residentialBloc = ResidentialBloc(
              ResidentialRepositoryImpl(ResidentialRemoteDataSource(context)),
            );
            residentialBloc.setContext(context); // esto para manejar token expirado
            return residentialBloc;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vecindapp',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: isAuthenticated ? AdminPage() : LoginPage(),
      ),
    );
  }
}
