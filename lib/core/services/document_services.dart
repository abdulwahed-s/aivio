import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';
import 'package:flutter/foundation.dart';

class DocumentService {
  static const List<String> supportedExtensions = [
    'pdf',
    'docx',
    'txt',
    'pptx',
  ];

  Future<PlatformFile?> pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedExtensions,
        withData: kIsWeb,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.single;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick document file: $e');
    }
  }

  Future<String> extractTextFromDocument(PlatformFile file) async {
    try {
      final extension = file.extension?.toLowerCase() ?? '';

      String text;
      switch (extension) {
        case 'pdf':
          text = await _extractFromPDF(file);
          break;
        case 'docx':
          text = await _extractFromDOCX(file);
          break;
        case 'txt':
          text = await _extractFromTXT(file);
          break;
        case 'pptx':
        case 'ppt':
          text = await _extractFromPPTX(file);
          break;
        default:
          throw Exception('Unsupported file format: .$extension');
      }

      if (text.trim().isEmpty) {
        throw Exception(
          'The document appears to be empty or contains only images',
        );
      }

      return text;
    } catch (e) {
      throw Exception('Failed to extract text from document: $e');
    }
  }

  Future<String> _extractFromPDF(PlatformFile file) async {
    try {
      PdfDocument document;
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File content is empty');
        }
        document = PdfDocument(inputBytes: file.bytes!);
      } else {
        if (file.path == null) {
          throw Exception('File path is missing');
        }
        final bytes = await File(file.path!).readAsBytes();
        document = PdfDocument(inputBytes: bytes);
      }

      String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      throw Exception('Failed to read PDF: $e');
    }
  }

  Future<String> _extractFromDOCX(PlatformFile file) async {
    try {
      List<int> bytes;
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File content is empty');
        }
        bytes = file.bytes!;
      } else {
        if (file.path == null) {
          throw Exception('File path is missing');
        }
        bytes = await File(file.path!).readAsBytes();
      }

      final archive = ZipDecoder().decodeBytes(bytes);

      final documentXml = archive.findFile('word/document.xml');

      if (documentXml == null) {
        throw Exception('Invalid DOCX file structure');
      }

      final content = documentXml.content as List<int>;
      final xmlString = String.fromCharCodes(content);

      final document = XmlDocument.parse(xmlString);
      final textNodes = document.findAllElements('w:t');

      final buffer = StringBuffer();
      for (var node in textNodes) {
        buffer.write(node.innerText);
        buffer.write(' ');
      }

      final paragraphs = document.findAllElements('w:p');
      if (buffer.isEmpty && paragraphs.isNotEmpty) {
        for (var para in paragraphs) {
          final texts = para.findAllElements('w:t');
          for (var text in texts) {
            buffer.write(text.innerText);
          }
          buffer.write('\n');
        }
      }

      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Failed to read DOCX: $e');
    }
  }

  Future<String> _extractFromTXT(PlatformFile file) async {
    try {
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File content is empty');
        }
        return String.fromCharCodes(file.bytes!);
      } else {
        if (file.path == null) {
          throw Exception('File path is missing');
        }
        return await File(file.path!).readAsString();
      }
    } catch (e) {
      throw Exception('Failed to read text file: $e');
    }
  }

  Future<String> _extractFromPPTX(PlatformFile file) async {
    try {
      List<int> bytes;
      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('File content is empty');
        }
        bytes = file.bytes!;
      } else {
        if (file.path == null) {
          throw Exception('File path is missing');
        }
        bytes = await File(file.path!).readAsBytes();
      }

      final archive = ZipDecoder().decodeBytes(bytes);

      final buffer = StringBuffer();

      for (final file in archive) {
        if (file.name.startsWith('ppt/slides/slide') &&
            file.name.endsWith('.xml')) {
          final content = file.content as List<int>;
          final xmlString = String.fromCharCodes(content);
          final xmlDoc = XmlDocument.parse(xmlString);

          final texts = xmlDoc
              .findAllElements('a:t')
              .map((e) => e.innerText.trim())
              .where((text) => text.isNotEmpty);

          for (var text in texts) {
            buffer.write(text);
            buffer.write(' ');
          }
          buffer.write('\n');
        }
      }

      return buffer.toString().trim();
    } catch (e) {
      throw Exception('Failed to read PowerPoint: $e');
    }
  }

  String getFileExtension(PlatformFile file) {
    return file.extension?.toLowerCase() ?? '';
  }

  bool isSupportedFile(PlatformFile file) {
    final extension = getFileExtension(file);
    return supportedExtensions.contains(extension);
  }

  String getFileTypeDescription(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'PDF Document';
      case 'docx':
        return 'Word Document';
      case 'txt':
        return 'Text File';
      case 'pptx':
      case 'ppt':
        return 'PowerPoint Presentation';
      default:
        return 'Unknown';
    }
  }
}
