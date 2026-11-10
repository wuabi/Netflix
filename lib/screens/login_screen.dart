import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../widgets/catalog_widgets.dart';

const String usuarioCorrecto = 'usuario@netflix.com';
const String passwordCorrecta = '1234';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.state});
  final AppState state;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  String? _error;

  @override
  void dispose() {
    _user.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    setState(() => _error = null);
    if (!_form.currentState!.validate()) return;
    if (_user.text.trim() == usuarioCorrecto &&
        _password.text == passwordCorrecta) {
      widget.state.clear();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _error = 'Usuario o contraseña incorrectos. Inténtalo de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5C0710), Color(0xFF21070A), Color(0xFF050505)],
            stops: [0, 0.42, 1],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(-0.65, -0.8),
                    radius: 1.25,
                    colors: [Color(0x557B0010), Colors.transparent],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 600;
                  final horizontal = compact ? 24.0 : 56.0;
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontal,
                              vertical: 30,
                            ),
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Brand(width: 170),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              compact ? 20 : 32,
                              compact ? 26 : 44,
                              compact ? 20 : 32,
                              72,
                            ),
                            child: Center(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 450,
                                ),
                                padding: EdgeInsets.all(compact ? 28 : 44),
                                decoration: BoxDecoration(
                                  color: const Color(0xE6080808),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF382124),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x44000000),
                                      blurRadius: 48,
                                      offset: Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: AutofillGroup(
                                  child: Form(
                                    key: _form,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        const Text(
                                          'Inicia sesión',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        TextFormField(
                                          key: const Key('login-user'),
                                          controller: _user,
                                          autofillHints: const [
                                            AutofillHints.username,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Usuario o correo electrónico',
                                          ),
                                          textInputAction: TextInputAction.next,
                                          validator: (value) =>
                                              value == null ||
                                                  value.trim().isEmpty
                                              ? 'Ingresa tu usuario.'
                                              : null,
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          key: const Key('login-password'),
                                          controller: _password,
                                          obscureText: _hidden,
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Contraseña',
                                            suffixIcon: IconButton(
                                              tooltip: _hidden
                                                  ? 'Mostrar contraseña'
                                                  : 'Ocultar contraseña',
                                              onPressed: () => setState(
                                                () => _hidden = !_hidden,
                                              ),
                                              icon: Icon(
                                                _hidden
                                                    ? Icons.visibility_outlined
                                                    : Icons
                                                          .visibility_off_outlined,
                                              ),
                                            ),
                                          ),
                                          onFieldSubmitted: (_) => _login(),
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Ingresa tu contraseña.'
                                              : null,
                                        ),
                                        if (_error != null) ...[
                                          const SizedBox(height: 18),
                                          Semantics(
                                            liveRegion: true,
                                            child: Text(
                                              _error!,
                                              style: const TextStyle(
                                                color: Color(0xFFFFBD8C),
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 30),
                                        ElevatedButton(
                                          key: const Key('login-submit'),
                                          onPressed: _login,
                                          child: const Text(
                                            'Iniciar sesión',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 28),
                                        const Text(
                                          'Tu próxima historia comienza aquí.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white60,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
