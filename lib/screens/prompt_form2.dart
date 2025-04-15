import 'package:flutter/material.dart';
import '../services/appscript_service.dart';

class PromptForm extends StatefulWidget {
  @override
  _PromptFormState createState() => _PromptFormState();
}

class _PromptFormState extends State<PromptForm> {
  final _promptController = TextEditingController();
  final _contextoManualController = TextEditingController();
  final _propositoManualController = TextEditingController();

  bool _enviando = false;
  String _mensaje = '';

  List<String> _contextosDisponibles = [];
  List<String> _propositosDisponibles = [];

  String? _contextoSeleccionado;
  String? _propositoSeleccionado;

  @override
  void initState() {
    super.initState();
    //_cargarOpcionesUnicas();
  }

  /*Future<void> _cargarOpcionesUnicas() async {
    try {
      final opciones = await obtenerOpcionesUnicas();
      setState(() {
        _contextosDisponibles = opciones['contexto'] ?? [];
        _propositosDisponibles = opciones['proposito'] ?? [];
      });
    } catch (e) {
      print('Error al cargar opciones: $e');
    }
  }*/

  Future<void> _enviar() async {
    final contextoFinal = _contextoSeleccionado == 'Otro'
        ? _contextoManualController.text
        : _contextoSeleccionado ?? '';

    final propositoFinal = _propositoSeleccionado == 'Otro'
        ? _propositoManualController.text
        : _propositoSeleccionado ?? '';

    final promptTexto = _promptController.text;

    if (contextoFinal.isEmpty || propositoFinal.isEmpty || promptTexto.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _enviando = true);

    final resultado = await enviarPrompt(
      contextoUso: contextoFinal,
      propositoUso: propositoFinal,
      promptTexto: promptTexto,
    );

    setState(() {
      _mensaje = resultado;
      _enviando = false;
    });

    if (resultado.contains('Prompt agregado')) {
      _promptController.clear();
      _contextoManualController.clear();
      _propositoManualController.clear();
      setState(() {
        _contextoSeleccionado = null;
        _propositoSeleccionado = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Prompt enviado exitosamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ $resultado')),
      );
    }
  }

  @override
  void dispose() {
    _promptController.dispose();
    _contextoManualController.dispose();
    _propositoManualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZtorePrompt')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Contexto de uso'),
              items: [
                ..._contextosDisponibles.map(
                      (ctx) => DropdownMenuItem(value: ctx, child: Text(ctx)),
                ),
                const DropdownMenuItem(value: 'Otro', child: Text('Otro...')),
              ],
              value: _contextoSeleccionado,
              onChanged: (value) {
                setState(() {
                  _contextoSeleccionado = value;
                });
              },
            ),
            if (_contextoSeleccionado == 'Otro')
              TextField(
                controller: _contextoManualController,
                decoration: const InputDecoration(labelText: 'Nuevo contexto'),
              ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Propósito de uso'),
              items: [
                ..._propositosDisponibles.map(
                      (p) => DropdownMenuItem(value: p, child: Text(p)),
                ),
                const DropdownMenuItem(value: 'Otro', child: Text('Otro...')),
              ],
              value: _propositoSeleccionado,
              onChanged: (value) {
                setState(() {
                  _propositoSeleccionado = value;
                });
              },
            ),
            if (_propositoSeleccionado == 'Otro')
              TextField(
                controller: _propositoManualController,
                decoration: const InputDecoration(labelText: 'Nuevo propósito'),
              ),
            const SizedBox(height: 16),

            TextField(
              controller: _promptController,
              decoration: const InputDecoration(labelText: 'Prompt'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _enviando ? null : _enviar,
              child: Text(_enviando ? 'Enviando...' : 'Guardar Prompt'),
            ),
            const SizedBox(height: 16),
            Text(_mensaje),
          ],
        ),
      ),
    );
  }
}
