import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ZtorePromptApp());
}

class ZtorePromptApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZtorePrompt',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PromptForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PromptForm extends StatefulWidget {
  @override
  _PromptFormState createState() => _PromptFormState();
}

class _PromptFormState extends State<PromptForm> {
  // Capítulo 2: Controladores y Validación
  final _contextoController = TextEditingController();
  final _propositoController = TextEditingController();
  final _promptController = TextEditingController();

  final _contextoFocus = FocusNode();
  final _propositoFocus = FocusNode();
  final _promptFocus = FocusNode();

  bool _enviando = false;
  bool _contextoInvalido = false;
  bool _propositoInvalido = false;
  bool _promptInvalido = false;

  // Capítulo 2: Función de envío con validación
  Future<void> enviarPrompt() async {
    final contexto = _contextoController.text.trim();
    final proposito = _propositoController.text.trim();
    final prompt = _promptController.text.trim();

    // Actualizar banderas de validación
    setState(() {
      _contextoInvalido = contexto.isEmpty;
      _propositoInvalido = proposito.isEmpty;
      _promptInvalido = prompt.isEmpty;
    });

    // Verificación y enfoque del primer campo vacío
    if (_contextoInvalido) {
      _contextoFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el campo "Contexto de uso"')),
      );
      return;
    }
    if (_propositoInvalido) {
      _propositoFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el campo "Propósito de uso"')),
      );
      return;
    }
    if (_promptInvalido) {
      _promptFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa el campo "Prompt"')),
      );
      return;
    }

    // Capítulo 3: Indicador de carga
    setState(() {
      _enviando = true;
    });

    final url = Uri.parse(
      'https://script.google.com/macros/s/AKfycbxqDr8t6pyaJm8EJN7B_rqccMcVA1QsiUGxcn_9UELHv8mqvWgkL06k0elWvFoHrtZX/exec'
          '?action=addPrompt'
          '&contextoUso=${Uri.encodeComponent(contexto)}'
          '&propositoUso=${Uri.encodeComponent(proposito)}'
          '&promptTexto=${Uri.encodeComponent(prompt)}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        _contextoController.clear();
        _propositoController.clear();
        _promptController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prompt enviado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
    } finally {
      setState(() {
        _enviando = false;
        // Restablece las banderas de error
        _contextoInvalido = false;
        _propositoInvalido = false;
        _promptInvalido = false;
      });
    }
  }

  @override
  void dispose() {
    _contextoController.dispose();
    _propositoController.dispose();
    _promptController.dispose();

    _contextoFocus.dispose();
    _propositoFocus.dispose();
    _promptFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capítulo 1: Diseño Centrado y Responsivo
    return Scaffold(
      appBar: AppBar(title: Text('ZtorePrompt')),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Campo: Contexto de uso
                      TextField(
                        controller: _contextoController,
                        focusNode: _contextoFocus,
                        decoration: InputDecoration(
                          labelText: 'Contexto de uso',
                          errorText: _contextoInvalido ? 'Campo requerido' : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Campo: Propósito de uso
                      TextField(
                        controller: _propositoController,
                        focusNode: _propositoFocus,
                        decoration: InputDecoration(
                          labelText: 'Propósito de uso',
                          errorText: _propositoInvalido ? 'Campo requerido' : null,
                        ),
                      ),
                      SizedBox(height: 12),
                      // Campo: Prompt
                      TextField(
                        controller: _promptController,
                        focusNode: _promptFocus,
                        decoration: InputDecoration(
                          labelText: 'Prompt',
                          errorText: _promptInvalido ? 'Campo requerido' : null,
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      // Capítulo 3: Botón con Indicador de Carga
                      ElevatedButton.icon(
                        onPressed: _enviando ? null : enviarPrompt,
                        icon: _enviando
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Icon(Icons.send),
                        label: Text(_enviando ? 'Enviando...' : 'Guardar Prompt'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
