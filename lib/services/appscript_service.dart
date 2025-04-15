import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ URL final confirmada como funcional
const String baseUrl = 'https://script.google.com/macros/s/AKfycbx76Bt_bsuJ20NRWxvx3Pz-hZlsvj7aOzWU15r-8X5IN9BKWoTMpMO6r0MyEc9tVnB5/exec';

/// 🔹 Enviar un nuevo prompt (acción: 'addPrompt') usando POST
Future<String> enviarPrompt({
  required String contextoUso,
  required String propositoUso,
  required String promptTexto,
}) async {
  final url = Uri.parse(baseUrl);

  try {
    final response = await http.post(
      url,
      body: {
        'action': 'addPrompt',
        'contextoUso': contextoUso,
        'propositoUso': propositoUso,
        'promptTexto': promptTexto,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      return 'Error: ${response.statusCode}';
    }
  } catch (e) {
    return 'Excepción: $e';
  }
}

/// 🔹 Leer opciones únicas desde Google Sheets (acción: 'getOptions')
Future<Map<String, List<String>>> obtenerOpcionesUnicas() async {
  final url = Uri.parse('$baseUrl?action=getOptions');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'contexto': List<String>.from(data['contexto']),
        'proposito': List<String>.from(data['proposito']),
      };
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error al obtener opciones únicas: $e');
  }
}
