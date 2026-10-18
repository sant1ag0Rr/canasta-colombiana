import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ProductService {
  final String baseUrl;

  ProductService(this.baseUrl);

  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final dynamic data = jsonDecode(decodedBody);

        if (data is! List) {
          throw const ApiException('El formato del catálogo recibido no es una lista');
        }

        return data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      if (response.statusCode == 404) {
        throw const ApiException('No se encontraron productos');
      }

      if (response.statusCode == 500) {
        throw const ApiException('El servidor no está disponible');
      }

      throw ApiException('Error HTTP ${response.statusCode}');
    } on TimeoutException {
      throw const ApiException('El servidor tardó demasiado en responder');
    } on SocketException {
      throw const ApiException('Sin conexión a internet o servidor no alcanzable');
    } on http.ClientException catch (e) {
      throw ApiException('Error de conexión con el servidor: ${e.message}');
    } on FormatException {
      throw const ApiException('Error en el formato de los datos recibidos');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error inesperado al cargar productos: $e');
    }
  }
}
