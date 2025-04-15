import 'package:flutter/material.dart';
import '../services/appscript_service.dart';

class PromptFormScreen extends StatefulWidget {
  const PromptFormScreen({super.key});

  @override
  State<PromptFormScreen> createState() => _PromptFormScreenState();
}

class _PromptFormScreenState extends State<PromptFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _contextoSeleccionado;
  String? _propositoSeleccionado;
  String? _nuevoContexto;
  String? _nuevoProposito;
  String _promptTexto = '';

  List<String> _contextos = [];
  List<String> _propositos = [];

  bool _cargandoOpciones = true;

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  Future<void> _cargarOpciones() async {
    try {
      final data = await obtenerOpcionesUnicas();
      setState(() {
        _contextos = data['contexto']!..sort();
        _propositos = data['proposito']!..sort();
        _cargandoOpciones = false;
      });
    } catch (e) {
      setState(() {
        _cargandoOpciones = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar opciones: $e')),
      );
    }
  }

  Future<void> _enviarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final contextoFinal = _contextoSeleccionado == 'CREAR_NUEVO'
        ? _nuevoContexto?.trim() ?? ''
        : _contextoSeleccionado ?? '';

    final propositoFinal = _propositoSeleccionado == 'CREAR_NUEVO'
        ? _nuevoProposito?.trim() ?? ''
        : _propositoSeleccionado ?? '';

    final respuesta = await enviarPrompt(
      contextoUso: contextoFinal,
      propositoUso: propositoFinal,
      promptTexto: _promptTexto.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(respuesta)),
    );

    _formKey.currentState!.reset();
    setState(() {
      _contextoSeleccionado = null;
      _propositoSeleccionado = null;
      _nuevoContexto = null;
      _nuevoProposito = null;
      _promptTexto = '';
    });

    // ✅ Cargar nuevamente las opciones desde Google Sheets
    await _cargarOpciones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear nuevo Prompt'),
      ),
      body: _cargandoOpciones
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // 🔹 Campo: Contexto de uso
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Contexto de uso',
                ),
                value: _contextoSeleccionado,
                items: [
                  ..._contextos.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  )),
                  const DropdownMenuItem(
                    value: 'CREAR_NUEVO',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('➕ Crear nuevo contexto'),
                      ],
                    ),
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    _contextoSeleccionado = value;
                    _nuevoContexto = null;
                  });
                },
                validator: (value) =>
                value == null ? 'Selecciona un contexto' : null,
              ),
              if (_contextoSeleccionado == 'CREAR_NUEVO')
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nuevo contexto',
                  ),
                  onSaved: (value) => _nuevoContexto = value,
                  validator: (value) {
                    if (_contextoSeleccionado == 'CREAR_NUEVO' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Ingresa un nuevo contexto';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),

              // 🔹 Campo: Propósito de uso
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Propósito de uso',
                ),
                value: _propositoSeleccionado,
                items: [
                  ..._propositos.map((p) => DropdownMenuItem(
                    value: p,
                    child: Text(p),
                  )),
                  const DropdownMenuItem(
                    value: 'CREAR_NUEVO',
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.green),
                        SizedBox(width: 8),
                        Text('➕ Crear nuevo propósito'),
                      ],
                    ),
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    _propositoSeleccionado = value;
                    _nuevoProposito = null;
                  });
                },
                validator: (value) =>
                value == null ? 'Selecciona un propósito' : null,
              ),
              if (_propositoSeleccionado == 'CREAR_NUEVO')
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nuevo propósito',
                  ),
                  onSaved: (value) => _nuevoProposito = value,
                  validator: (value) {
                    if (_propositoSeleccionado == 'CREAR_NUEVO' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Ingresa un nuevo propósito';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),

              // 🔹 Campo: Texto del prompt
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Texto del prompt',
                ),
                maxLines: 3,
                onSaved: (value) => _promptTexto = value ?? '',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa un prompt'
                    : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _enviarFormulario,
                child: const Text('Guardar Prompt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
