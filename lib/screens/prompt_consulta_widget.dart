import 'package:flutter/material.dart';
import '../services/appscript_service.dart';

class PromptConsultaWidget extends StatefulWidget {
  const PromptConsultaWidget({super.key});

  @override
  State<PromptConsultaWidget> createState() => _PromptConsultaWidgetState();
}

class _PromptConsultaWidgetState extends State<PromptConsultaWidget> {
  String? contextoSeleccionado;
  String? propositoSeleccionado;

  List<String> contextos = [];
  List<String> propositos = [];
  List<Map<String, dynamic>> promptsEncontrados = [];

  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  Future<void> _cargarOpciones() async {
    try {
      final data = await obtenerOpcionesUnicas();
      setState(() {
        contextos = data['contexto']!..sort();
        propositos = data['proposito']!..sort();
      });
    } catch (e) {
      debugPrint('Error cargando opciones: $e');
    }
  }

  Future<void> buscarPrompts() async {
    if (contextoSeleccionado == null || propositoSeleccionado == null) return;

    setState(() => cargando = true);

    try {
      final data = await consultarPromptsPorContextoYProposito(
        contextoSeleccionado!,
        propositoSeleccionado!,
      );

      setState(() {
        promptsEncontrados = List<Map<String, dynamic>>.from(data);
        cargando = false;
      });
    } catch (e) {
      setState(() => cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al consultar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        const Text(
          '🔍 Consultar Prompts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // 🔹 Dropdown: Contexto
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Contexto de uso'),
          value: contextoSeleccionado,
          items: contextos
              .map((ctx) => DropdownMenuItem(value: ctx, child: Text(ctx)))
              .toList(),
          onChanged: (value) {
            setState(() {
              contextoSeleccionado = value;
            });
          },
        ),
        const SizedBox(height: 12),

        // 🔹 Dropdown: Propósito
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Propósito de uso'),
          value: propositoSeleccionado,
          items: propositos
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) {
            setState(() {
              propositoSeleccionado = value;
            });
          },
        ),
        const SizedBox(height: 16),

        // 🔹 Botón de búsqueda
        ElevatedButton(
          onPressed: buscarPrompts,
          child: const Text('Buscar Prompts'),
        ),

        const SizedBox(height: 20),

        // 🔹 Resultados
        if (cargando)
          const Center(child: CircularProgressIndicator())
        else if (promptsEncontrados.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: promptsEncontrados.map((fila) {
              final promptTexto = fila['prompt'];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(promptTexto),
                ),
              );
            }).toList(),
          )
        else if (contextoSeleccionado != null && propositoSeleccionado != null)
            const Text('No se encontraron prompts con esos filtros.'),
      ],
    );
  }
}
