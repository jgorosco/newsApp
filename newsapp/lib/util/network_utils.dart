import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkUtils {
  static String productionHost = 'belle-essence-api.jedai.group';
  static String developmentHost = 'belle-essence-api.jedai.group';
  static String host = productionHost;
  bool developer = false;

  final JsonDecoder _decoder = new JsonDecoder();
  final JsonEncoder _encoder = new JsonEncoder();

  Map<String, String> headers = {"Content-Type": "application/json;charset=UTF-8"};
  Map<String, String> cookies = {};

  NetworkUtils() {
    determinar_ambiente();
  }

  void determinar_ambiente() async {
    assert(() {
      developer = true;
      return true;
    }());
    if (developer) {
      try {
        developmentHost = 'http://aqueous-harbor-64602.herokuapp.com';
      } catch (e) {}
      host = developmentHost;
    }
  }

  void _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        this.cookies[key] = value;
      }
    }
  }

  void deleteCookies() {
    cookies = {};
  }

  void deleteHeaders(key) {
    headers.remove(key);
  }

  void addHeaders(String name, String value) {
    headers[name] = value;
  }

  Future<dynamic> getExternal(String url, {params}) {
    return http.get(buildUri(url)).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 && res != null) {
        var msg = handleError(res);
        throw new Exception(msg);
      }
      if (res == null) {
        throw new Exception("Error desconocido");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> get(String url, {params}) {
    var uri = buildUri(url, params: params);

    return http.get(uri, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 && res != null) {
        var msg = handleError(res);
        throw new Exception(msg);
      }
      if (res == null) {
        throw new Exception("Error desconocido");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {body, encoding, params}) {
    var uri = buildUri(url, params: params);

    return http
        .post(uri, body: jsonEncode(body), headers: headers, encoding: encoding)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode >= 400 && res != null) {
        var msg = handleError(res);
        throw new Exception(msg);
      }
      if (res == null) {
        throw new Exception("Error desconocido");
      }

      return _decoder.convert(res);
    });
  }

  Future<dynamic> delete(String url, {params}) {
    var uri = buildUri(url, params: params);

    return http.delete(uri, headers: headers).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400 && res != null) {
        var msg = handleError(res);
        throw new Exception(msg);
      }
      if (res == null) {
        throw new Exception("Error desconocido");
      }
      return _decoder.convert(res);
    });
  }

  Uri buildUri(url, {params}) {
    if (!developer || host.contains("group")) {
      return params != null
          ? Uri.https(host, url, params)
          : Uri.https(host, url);
    } else {
      return params != null ? Uri.http(host, url, params) : Uri.http(host, url);
    }
  }

  showSnackBar(GlobalKey<ScaffoldState> scaffoldKey, String message) {
    if (scaffoldKey != null) {
      scaffoldKey.currentState!.showSnackBar(new SnackBar(
        content: new Text(message),
      ));
    }
  }

  /**
   * decodifica el formato json de error q por defecto manda spring framework
   */
  handleError(String res) {
    var error = _decoder.convert(res);
    var msg = 'Error desconocido';
    try {
      if (error.containsKey('message')) {
        var temp = error['message'];
        if (temp is String) {
          msg = temp;
        }
      }
    } catch (e) {}
    return msg;
  }
}
