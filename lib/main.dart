import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventario_alfa/firebase_options.dart';
import 'package:inventario_alfa/newsheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/new': (context) => const Newsheet(),
      },
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isValid = true;

  Future<void> _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isValid = false;
      });
      return;
    }

    setState(() {
      _isValid = true;
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      var user = userCredential.user;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Iniciando sesión como ${user!.email}')),
      );

      Navigator.pushNamed(context, '/new');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado.')),
        );
      } else if (e.code == 'wrong-password') {
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña incorrecta.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error. Intente nuevamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 206, 221, 246),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Bodega",
              style: TextStyle(
                color: Colors.black,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Login Familia Avila Mares",
              style: TextStyle(
                color: Colors.black,
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30.0),
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email",
                prefixIcon: const Icon(Icons.mail, color: Colors.black),
                errorText: _isValid ? null : 'Email or password cannot be empty',
              ),
            ),
            const SizedBox(height: 25.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                errorText: _isValid ? null : 'Email or password cannot be empty',
              ),
            ),
            const SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 24, 26, 26)), // Verde
                  ),  // Cambia el color aquí),
                onPressed: () {
                  _login(context); // Llama a la función de login con el contexto correcto
                },
                child: const Text('Iniciar Sesión'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
