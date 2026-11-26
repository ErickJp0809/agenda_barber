import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agenda_barber/main.dart';
import 'package:agenda_barber/tema.dart';
import 'dart:convert';

class MiLogin extends StatefulWidget {
  const MiLogin({super.key});

  @override
  State<MiLogin> createState() => _MiLoginState();
}

class _MiLoginState extends State<MiLogin> {

  final TextEditingController usuario = TextEditingController();
  final TextEditingController password = TextEditingController();

  final String usuarioCorrecto = 'admin';
 
  final String passwordHash = '\$2a\$10\$Nr.VFPgOyAwlO47BF6d88OoMOHoxBrlHot4fJtm6rXYJL30.8RAtW';

  bool ocultarPassword = true;
  bool cargando = true;

  Map<String, String> usuariosRegistrados = {};

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final prefs = await SharedPreferences.getInstance();

    String? datos = prefs.getString('usuarios');

    if (datos != null) {
      usuariosRegistrados = Map<String, String>.from(
        jsonDecode(datos),
      );
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  // INICIAR SESION
  void iniciarSesion(BuildContext pantallaContext) {

    final String nombre = usuario.text.trim();
    final String clave = password.text;

    bool accesoCorrecto = false;

    // VERIFICAR ADMINISTRADOR
    if (nombre == usuarioCorrecto &&
        BCrypt.checkpw(clave, passwordHash)) {

      accesoCorrecto = true;

    }

    // VERIFICAR USUARIOS REGISTRADOS
    else if (usuariosRegistrados.containsKey(nombre)) {

      accesoCorrecto = BCrypt.checkpw(
        clave,
        usuariosRegistrados[nombre]!,
      );

    }

    if (accesoCorrecto) {

      Navigator.pushReplacement(
        pantallaContext,
        MaterialPageRoute(
          builder: (context) => const MainApp(),
        ),
      );

    } else {

      ScaffoldMessenger.of(pantallaContext).showSnackBar(
        const SnackBar(
          content: Text('Usuario o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );

    }
  }

  // ABRIR REGISTRO
  void abrirRegistro(BuildContext pantallaContext) {

    Navigator.push(
      pantallaContext,
      MaterialPageRoute(
        builder: (context) => RegistroPage(
          usuarios: usuariosRegistrados,

          onRegistrar: (nombre, hash) {
            setState(() {
              usuariosRegistrados[nombre] = hash;
            });
          },
        ),
      ),
    );

  }

  @override
  void dispose() {
    usuario.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaApp,

      home: Builder(
        builder: (BuildContext pantallaContext) {

          return Scaffold(
            backgroundColor: const Color(0xFF111111),

            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),

                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Icon(
                        Icons.content_cut,
                        color: Color(0xFFD4AF37),
                        size: 75,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'BARBER SHOP',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Inicia sesión en tu cuenta',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 35),

                      // CAMPO USUARIO
                      TextField(
                        controller: usuario,
                        style: const TextStyle(color: Colors.white),

                        decoration: InputDecoration(
                          labelText: 'Usuario',

                          labelStyle: const TextStyle(
                            color: Color(0xFFD4AF37),
                          ),

                          prefixIcon: const Icon(
                            Icons.person,
                            color: Color(0xFFD4AF37),
                          ),

                          filled: true,
                          fillColor: const Color(0xFF222222),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CAMPO CONTRASEÑA
                      TextField(
                        controller: password,
                        obscureText: ocultarPassword,
                        style: const TextStyle(color: Colors.white),

                        onSubmitted: (_) {
                          if (!cargando) {
                            iniciarSesion(pantallaContext);
                          }
                        },

                        decoration: InputDecoration(
                          labelText: 'Contraseña',

                          labelStyle: const TextStyle(
                            color: Color(0xFFD4AF37),
                          ),

                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(0xFFD4AF37),
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              ocultarPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFFD4AF37),
                            ),

                            onPressed: () {
                              setState(() {
                                ocultarPassword = !ocultarPassword;
                              });
                            },
                          ),

                          filled: true,
                          fillColor: const Color(0xFF222222),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // BOTON INICIAR SESION
                      SizedBox(
                        width: double.infinity,
                        height: 55,

                        child: ElevatedButton(
                          onPressed: cargando
                              ? null
                              : () {
                                  iniciarSesion(pantallaContext);
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.black,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: cargando
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'INICIAR SESIÓN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // BOTON CREAR CUENTA
                      TextButton(
                        onPressed: cargando
                            ? null
                            : () {
                                abrirRegistro(pantallaContext);
                              },

                        child: const Text(
                          '¿No tienes cuenta? Crear cuenta',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Agenda tu estilo',
                        style: TextStyle(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =====================================
// PANTALLA DE REGISTRO
// =====================================

class RegistroPage extends StatefulWidget {

  final Map<String, String> usuarios;
  final Function(String, String) onRegistrar;

  const RegistroPage({
    super.key,
    required this.usuarios,
    required this.onRegistrar,
  });

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {

  final TextEditingController nuevoUsuario = TextEditingController();
  final TextEditingController nuevaPassword = TextEditingController();
  final TextEditingController confirmarPassword = TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;
  bool guardando = false;

  // REGISTRAR CUENTA
  Future<void> registrarCuenta() async {

    final String nombre = nuevoUsuario.text.trim();
    final String clave = nuevaPassword.text;
    final String confirmacion = confirmarPassword.text;

    if (nombre.isEmpty || clave.isEmpty || confirmacion.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    if (nombre.toLowerCase() == 'admin') {
      mostrarMensaje('Ese usuario está reservado');
      return;
    }

    if (widget.usuarios.containsKey(nombre)) {
      mostrarMensaje('Ese usuario ya existe');
      return;
    }

    if (clave.length < 6) {
      mostrarMensaje('La contraseña debe tener mínimo 6 caracteres');
      return;
    }

    if (clave != confirmacion) {
      mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() {
      guardando = true;
    });

    try {

      // GENERAR HASH CON BCRYPT
      final String hash = BCrypt.hashpw(
        clave,
        BCrypt.gensalt(),
      );

      debugPrint('CONTRASEÑA ORIGINAL: $clave');
      debugPrint('CONTRASEÑA HASH: $hash');

      // GUARDAR USUARIO Y HASH
      final prefs = await SharedPreferences.getInstance();

      final Map<String, String> usuariosActualizados = {
        ...widget.usuarios,
        nombre: hash,
      };

      await prefs.setString(
        'usuarios',
        jsonEncode(usuariosActualizados),
      );

      widget.onRegistrar(nombre, hash);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada correctamente!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      mostrarMensaje('Error al crear la cuenta');

    } finally {

      if (mounted) {
        setState(() {
          guardando = false;
        });
      }

    }
  }

  // MOSTRAR MENSAJES
  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
      ),
    );
  }

  @override
  void dispose() {
    nuevoUsuario.dispose();
    nuevaPassword.dispose();
    confirmarPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: const Color(0xFF111111),
        foregroundColor: const Color(0xFFD4AF37),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Icon(
                  Icons.person_add_alt_1,
                  size: 75,
                  color: Color(0xFFD4AF37),
                ),

                const SizedBox(height: 20),

                const Text(
                  'NUEVA CUENTA',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // NUEVO USUARIO
                TextField(
                  controller: nuevoUsuario,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    labelText: 'Nombre de usuario',
                    labelStyle: const TextStyle(
                      color: Color(0xFFD4AF37),
                    ),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFFD4AF37),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222222),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // NUEVA CONTRASEÑA
                TextField(
                  controller: nuevaPassword,
                  obscureText: ocultarPassword,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(
                      color: Color(0xFFD4AF37),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFFD4AF37),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFD4AF37),
                      ),
                      onPressed: () {
                        setState(() {
                          ocultarPassword = !ocultarPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222222),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CONFIRMAR CONTRASEÑA
                TextField(
                  controller: confirmarPassword,
                  obscureText: ocultarConfirmacion,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    labelStyle: const TextStyle(
                      color: Color(0xFFD4AF37),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFFD4AF37),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ocultarConfirmacion
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFD4AF37),
                      ),
                      onPressed: () {
                        setState(() {
                          ocultarConfirmacion = !ocultarConfirmacion;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFF222222),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // BOTON CREAR CUENTA
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: guardando ? null : registrarCuenta,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),

                    child: guardando
                        ? const CircularProgressIndicator()
                        : const Text(
                            'CREAR CUENTA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
