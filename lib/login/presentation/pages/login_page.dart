import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vecindapp_residente/register/presentation/screen/RegisterPage.dart';
import 'dart:async';
import '../../../login/presentation/blocs/auth_bloc.dart';
import '../../../home/presentation/pages/admin_page.dart';
import '../widgets/input.dart';
import '../widgets/button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _showForm = false;
  bool _isLogin = true;
  bool _isKeyboardVisible = false;

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration.zero, () {
      _toggleForm(true);
    });
  }

  void _toggleForm(bool login) {
    setState(() {
      _isLogin = login;
      _showForm = true;
    });
    _controller.forward(from: 0.0);
  }

  void _scrollToFocusedField(BuildContext context) {
    Timer(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        final currentPosition = _scrollController.position.pixels;
        final targetPosition = currentPosition + 120;

        final maxScroll = _scrollController.position.maxScrollExtent;
        final scrollTo = targetPosition.clamp(0.0, maxScroll);

        _scrollController.animateTo(
          scrollTo,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _resetForm() {
    setState(() {
      _showForm = false;
      _controller.reset();
      _confirmPasswordController.clear();
    });
  }

  void _submitForm(BuildContext context) {
    if (_isLogin) {
      context.read<AuthBloc>().add(
        LoginEvent(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registro no implementado aún")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    _isKeyboardVisible = bottomInset > 0;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            _buildBackground(),
            SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 25,
                    right: 25,
                    bottom: _isKeyboardVisible ? bottomInset + 20 : 20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: _isKeyboardVisible ? 15 : 30),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height:
                                  _isKeyboardVisible
                                      ? MediaQuery.of(context).size.height *
                                          0.15
                                      : MediaQuery.of(context).size.height *
                                          0.25,
                              child: _buildLogo(context),
                            ),
                            AnimatedOpacity(
                              opacity: _isKeyboardVisible ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: const Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  'Bienvenido a tu hogar...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: _isKeyboardVisible ? 10 : 20,
                            bottom: 20,
                          ),
                          child:
                              _showForm
                                  ? _buildFormContainer(context)
                                  : _buildInitialButtons(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(decoration: const BoxDecoration(color: Color(0xFF003C8F)));
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      'assets/logoVA1.png',
      height: MediaQuery.of(context).size.height * 0.25,
      fit: BoxFit.contain,
    );
  }

  Widget _buildInitialButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _toggleForm(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Iniciar Sesión",
              style: TextStyle(
                color: Color(0xFF003C8F),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildFormContainer(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error en la autenticación"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8),
              ],
            ),
            child: Column(
              children: [
                Input(
                  controller: _usernameController,
                  hintText: "Correo",
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                Input(
                  controller: _passwordController,
                  hintText: "Contraseña",
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                state is AuthLoading
                    ? const CircularProgressIndicator(color: Color(0xFF003C8F))
                    : Button(
                      text: "Iniciar Sesión",
                      onPressed: () => _submitForm(context),
                    ),
                TextButton(
                  onPressed: _resetForm,
                  child: const Text(
                    "Volver",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Button(
                  text: "Register",
                  onPressed: () {
                      Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Registerpage()),
                    );
                    
                  },
                ),
                const SizedBox(height: 15),
                Button(
                  text: "Home",
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AdminPage()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
