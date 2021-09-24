import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:newsapp/dto/Reporte.dart';
import 'package:newsapp/util/network_utils.dart';
import 'package:http/http.dart' as http;

List<Reporte> parseReportes(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Reporte>((json) => Reporte.fromJson(json)).toList();
}

class ReporteSrv {
  NetworkUtils? net;
  List<Reporte> reportes = <Reporte>[];

  ReporteSrv(NetworkUtils net) {
    this.net = net;
  }

  Future<List<Reporte>> loadReportes(http.Client client, bool isFake) async {
    late http.Response response;
    try {
      if(isFake){
        response = await http.get(Uri.parse('https://aqueous-harbor-64602.herokuapp.com/api/noticias/fakes'));
      }else{
        response = await http.get(Uri.parse('https://aqueous-harbor-64602.herokuapp.com/api/noticias/reales'));
      }
      return compute(parseReportes, response.body);
    } catch (e) {
      throw Exception('No se pudieron cargar los reportes');
    }
  }

  Future<Reporte?> createReporte(String nombres, int edad, String coordenadas,
      String noticia, String sector, String titulo) async {
    final response = await http.post(
      Uri.parse('https://aqueous-harbor-64602.herokuapp.com/api/noticia'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': nombres,
        'edad' : edad,
        'sector': sector,
        'coordenadas': coordenadas,
        'titulo': titulo,
        'noticia': noticia
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return Reporte.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception(response.reasonPhrase);
    }
  }
}
