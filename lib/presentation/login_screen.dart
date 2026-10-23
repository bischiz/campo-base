import 'package:campo_base/temi.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campo_base/bloc/auth/auth_bloc.dart';
import 'package:campo_base/presentation/mainScreen.dart';
import 'package:intl/intl.dart'; // Importante per formattare la data

enum AuthMode { login, register }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController(); // Controller data nascita

  var _authMode = AuthMode.login;
  final _formKey = GlobalKey<FormState>();

  // Variabili per la registrazione
  DateTime? _selectedDate;
  bool _acceptedEULA = false;
  final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  final usernameRegex = RegExp(r'^[a-zA-Z0-9._!\$\\/\s|=\-#]{3,}$');
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
  }

  // Logica validazione età (> 18 anni)
  bool _isAdult(DateTime? birthDate) {
    if (birthDate == null) return false;
    final now = DateTime.now();
    // Calcolo preciso
    final age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      // Non ha ancora compiuto gli anni quest'anno
      return (age - 1) >= 18;
    }
    return age >= 18;
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    if (_authMode == AuthMode.login) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    } else {
      // Validazioni extra per registrazione
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le password non coincidono")));
        return;
      }
      if (!_acceptedEULA) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Devi accettare l'EULA per registrarti")));
        return;
      }
      if (!_isAdult(_selectedDate)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Devi avere almeno 18 anni")));
        return;
      }

      context.read<AuthBloc>().add(
            SignUpRequested(
              username: _nicknameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              passwordConfirm: _confirmPasswordController.text.trim(),
              birthDate: _selectedDate!,
            ),
          );
    }
  }

  // Mostra il Date Picker
// Mostra il Date Picker
  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // ~18 anni fa
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) return;
      setState(() {
        _selectedDate = pickedDate;
        // Qui la data verrà comunque formattata come 25/12/2000 grazie a DateFormat
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    });
  }

  // Dialog per Password Dimenticata
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color.fromARGB(240, 240, 240, 240),
        title: const Text(
          "Password Dimenticata",
          style: TextStyle(color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Inserisci la tua email per ricevere il link di reset."),
            const SizedBox(height: 10),
            TextField(
              controller: resetEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Annulla"),
          ),
          ElevatedButton(
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                context.read<AuthBloc>().add(PasswordResetRequested(email: email));
                Navigator.of(ctx).pop();
              }
            },
            child: const Text("Invia"),
          ),
        ],
      ),
    );
  }

  // Dialog EULA
  void _showEulaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(240, 240, 240, 240),
          title: const Text('EULA', style: TextStyle(color: Colors.black)),
          content: SingleChildScrollView(
            child: _buildEulaText(), // Testo estratto in funzione
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _authMode == AuthMode.login;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Color.fromARGB(170, 10, 132, 202)],
            //colors: [Theme.of(context).colorScheme.primary, Color.fromARGB(255, 66, 157, 249)],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainScreen()));
            }
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
            if (state is PasswordResetSent) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text(
                    "Email Inviata",
                    style: TextStyle(color: Colors.black),
                  ),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("OK"),
                    )
                  ],
                ),
              );
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(),
                  Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return Center(
                                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                          }
                          return _buildAuthForm(state, isLogin);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'images/logo2.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.business_rounded, size: 80, color: odysseyWhite);
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _authMode == AuthMode.login ? 'Bentornato!' : 'Crea un Account',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: odysseyWhite),
        ),
        const SizedBox(height: 8),
        Text(
          _authMode == AuthMode.login ? 'Accedi per continuare' : 'Registrati per iniziare',
          style: const TextStyle(fontSize: 16, color: odysseyWhite),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAuthForm(AuthState state, bool isLogin) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isLogin) ...[
            TextFormField(
              maxLength: 40,
              controller: _nicknameController,
              decoration: _buildInputDecoration('Nickname', Icons.person_outline),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Inserisci un nickname';
                if (value.length < 3) return 'Almeno 3 caratteri';
                // PocketBase spesso non ama gli spazi o caratteri speciali negli username
                if (!usernameRegex.hasMatch(value)) return 'Solo lettere, numeri e _';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: _buildInputDecoration('Email', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Inserisci email';
                if (!emailRegex.hasMatch(value.trim())) return 'Email non valida';
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          if (isLogin) ...[
            TextFormField(
              maxLength: 40,
              controller: _emailController,
              decoration: _buildInputDecoration('Username o email', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Inserisci le credenziali';
                if (value.trim().length < 3) return 'Inserisci almeno 3 caratteri';
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: _passwordController,
            decoration: _buildPasswordDecoration('Password'),
            obscureText: !_passwordVisible,
            validator: (value) => value!.length < 8 ? 'Password troppo corta' : null,
          ),
          if (isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showForgotPasswordDialog,
                child: Text(
                  "Password dimenticata?",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12),
                ),
              ),
            ),
          if (!isLogin) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: _buildPasswordDecoration('Conferma Password'),
              obscureText: true,
              validator: (value) => value != _passwordController.text ? 'Le password non coincidono' : null,
            ),
            const SizedBox(height: 16),
            // Campo Data di Nascita
            TextFormField(
              controller: _birthDateController,
              readOnly: true,
              onTap: _presentDatePicker,
              decoration: _buildInputDecoration('Data di nascita', Icons.calendar_today),
              validator: (value) => value!.isEmpty ? 'Inserisci data di nascita' : null,
            ),
            const SizedBox(height: 16),
            // Checkbox EULA
            Row(
              children: [
                Checkbox(
                  value: _acceptedEULA,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _acceptedEULA = newValue!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Ho letto ed accetto l\'',
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(
                          text: 'EULA',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _showEulaDialog,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: odysseyWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _submitForm,
            child: Text(isLogin ? 'ACCEDI' : 'REGISTRATI', style: const TextStyle(color: odysseyWhite)),
          ),
          const SizedBox(height: 16),

          // Divisore visivo
          const Row(children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("OPPURE")),
            Expanded(child: Divider()),
          ]),

          const SizedBox(height: 16),

          // Bottone Google
          /*OutlinedButton.icon(
            onPressed: () {
              // Scatena l'evento del Bloc
              context.read<AuthBloc>().add(GoogleLoginRequested());
            },
            icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
            // Oppure usa FontAwesomeIcons.google se hai il pacchetto
            label: const Text("Accedi con Google", style: TextStyle(color: Colors.black87)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),*/
          TextButton(
            onPressed: _switchAuthMode,
            child: Text(
              isLogin ? 'Non hai un account? Registrati' : 'Hai già un account? Accedi',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: odysseyGrey),
      prefixIcon: Icon(icon, color: odysseyGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  InputDecoration _buildPasswordDecoration(String label) {
    return InputDecoration(
      labelText: label,
      prefixIcon: const Icon(Icons.lock_outline, color: odysseyGrey),
      // Aggiungi questo suffixIcon
      suffixIcon: IconButton(
        icon: Icon(
          _passwordVisible ? Icons.visibility : Icons.visibility_off,
          color: odysseyGrey,
        ),
        onPressed: () {
          setState(() {
            _passwordVisible = !_passwordVisible;
          });
        },
      ),
      // ... resto dei bordi uguali a prima
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  // Testo EULA estratto e formattato
  Widget _buildEulaText() {
    return RichText(
      text: const TextSpan(
        style: TextStyle(color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: "Contratto di Licenza per l'Utente Finale\n\n",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          TextSpan(
            text:
                "Questo Contratto di Licenza per l'Utente Finale \"EULA\" è un accordo legale tra l’Utente Finale e l’autore del software relativo all'uso della nostra applicazione “Campo Base”.\n",
          ),
          TextSpan(
            text: "\nAccettazione del Contratto:\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                "Prima di utilizzare il Software, devi leggere attentamente e accettare tutti i termini e le condizioni di questo EULA. L'uso del Software implica la tua accettazione di tali termini e condizioni.\n",
          ),
          TextSpan(
            text: "\nLicenza d'uso:\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                "Con la tua accettazione di questo EULA, ti concediamo una licenza non esclusiva, non trasferibile e limitata per utilizzare il Software esclusivamente secondo quanto stabilito in questo documento.\n",
          ),
          TextSpan(
            text: "\nProprietà Intellettuale:\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                "Riconosci che tutti i diritti di proprietà intellettuale relativi al Software rimangono di nostra proprietà.\n",
          ),
          TextSpan(
            text: "\nUtilizzo Responsabile:\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                "L'Utente Finale si impegna a utilizzare il Software in modo responsabile. Ciò include l'obbligo di non pubblicare, condividere o inviare contenuti inappropriati o offensivi.\n",
          ),
          TextSpan(
            text: "\nMonitoraggio e Azioni Correttive:\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text:
                "Ci riserviamo il diritto di monitorare l'uso del Software e di prendere misure correttive in caso di comportamenti inappropriati.\n",
          ),
          TextSpan(
            text: "\nAccettazione:\n",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: "Con l'uso del Software, accetti di essere vincolato da questo EULA.",
          ),
        ],
      ),
    );
  }
}
