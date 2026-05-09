import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;

import '../models/memory_model.dart';

class HashService {

  /// Genera un hash perceptual simple para una imagen
  /// Usa diferencia de píxeles (similar a pHash pero más simple)
  static Future<String> generateImageHash(String imagePath) async {
    try {
      // Cargar imagen
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return '';

      // Redimensionar a 8x8 para simplificar
      final resized = img.copyResize(image, width: 8, height: 8);

      // Convertir a escala de grises
      final grayscale = img.grayscale(resized);

      // Calcular el valor promedio de los píxeles
      int sum = 0;
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final pixel = grayscale.getPixel(x, y);
          final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).toInt();
          sum += luminance;
        }
      }
      final average = sum / 64;

      // Generar el hash (1 si el píxel es mayor al promedio, 0 si no)
      StringBuffer hash = StringBuffer();
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final pixel = grayscale.getPixel(x, y);
          final luminance = (0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b).toInt();
          hash.write(luminance >= average ? '1' : '0');
        }
      }

      // Convertir a hexadecimal para almacenar más compacto
      return _binaryToHex(hash.toString());

    } catch (e) {
      print('Error generando hash: $e');
      return '';
    }
  }

  /// Convierte string binario a hexadecimal
  static String _binaryToHex(String binary) {
    if (binary.length % 4 != 0) {
      binary = binary.padRight(binary.length + (4 - binary.length % 4), '0');
    }

    StringBuffer hex = StringBuffer();
    for (int i = 0; i < binary.length; i += 4) {
      final chunk = binary.substring(i, i + 4);
      final decimal = int.parse(chunk, radix: 2);
      hex.write(decimal.toRadixString(16));
    }
    return hex.toString();
  }

  /// Convierte hexadecimal a binario
  static String _hexToBinary(String hex) {
    StringBuffer binary = StringBuffer();
    for (int i = 0; i < hex.length; i++) {
      final decimal = int.parse(hex[i], radix: 16);
      final binaryChunk = decimal.toRadixString(2).padLeft(4, '0');
      binary.write(binaryChunk);
    }
    return binary.toString();
  }

  /// Calcula la distancia de Hamming entre dos hashes
  static int calculateHammingDistance(String hash1, String hash2) {
    if (hash1.isEmpty || hash2.isEmpty) return 999;

    try {
      final binary1 = _hexToBinary(hash1);
      final binary2 = _hexToBinary(hash2);

      if (binary1.length != binary2.length) return 999;

      int distance = 0;
      for (int i = 0; i < binary1.length; i++) {
        if (binary1[i] != binary2[i]) {
          distance++;
        }
      }
      return distance;

    } catch (e) {
      print('Error calculando distancia: $e');
      return 999;
    }
  }

  /// Encuentra el recuerdo más similar basado en hashes
  /// Devuelve el recuerdo y la distancia de Hamming
  /// ¿Dónde se compara realmente?
  ///
  static SimilarityResult findBestMatch(
      String scannedHash,
      List<Memory> memories,
      ) {
    Memory? bestMatch;
    int bestDistance = 999;
    String bestHash = '';

    for (final memory in memories) {
      for (final storedHash in memory.imageHashes) {
        final distance = calculateHammingDistance(scannedHash, storedHash);

        if (distance < bestDistance) {
          bestDistance = distance;
          bestMatch = memory;
          bestHash = storedHash;
        }
      }
    }

    return SimilarityResult(
      memory: bestMatch,
      distance: bestDistance,
      matchedHash: bestHash,
    );
  }
}

/// Resultado de la búsqueda de similitud
class SimilarityResult {
  final Memory? memory;
  final int distance;
  final String matchedHash;

  SimilarityResult({
    this.memory,
    required this.distance,
    required this.matchedHash,
  });

  /// Umbral de similitud (menor distancia = más similar)
  /// 0-10: Muy similar
  /// 11-30: Similar
  /// 31-50: Poco similar
  /// >50: Diferente
  bool get isMatch => memory != null && distance <= 30;
  bool get isExactMatch => distance <= 10;
  bool get isPossibleMatch => distance <= 50;
}