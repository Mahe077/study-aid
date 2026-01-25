import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FileTextExtractorService {
  Future<String> extractText(String fileUrl, String fileType) async {
    // 1. Download the file if it's a remote URL
    final file = await _downloadFile(fileUrl, fileType);
    
    // 2. Extract text based on file type
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return await _extractPdfText(file);
      case 'txt':
        return await _extractTxtText(file);
      case 'doc':
      case 'docx':
        // For now, we return a message that doc/docx are not fully supported for text extraction 
        // without heavy dependencies, or we can try to read as plain text if it happens to work (unlikely for binary docx)
        // Ideally we would use a package like 'docx_to_text' but it is not in pubspec.
        // We will throw a specific error so UI can handle it.
        throw Exception('DOC/DOCX summarization is currently not supported.');
      default:
        throw Exception('Unsupported file type for summarization: $fileType');
    }
  }

  Future<File> _downloadFile(String url, String extension) async {
    // If it's already a local path, return it
    if (!url.startsWith('http')) {
      return File(url);
    }
    
    // print('Attempting to download file from: $url'); 

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_file_${DateTime.now().millisecondsSinceEpoch}.$extension');

      // Check if it's a Firebase Storage URL
      if (url.contains('firebasestorage.googleapis.com') || url.startsWith('gs://')) {
        try {
          // print('Using Firebase Storage SDK...');
          await FirebaseStorage.instance.refFromURL(url).writeToFile(file);
          return file;
        } catch (e) {
          // print('Firebase Storage download failed: $e. Falling back to HTTP.');
          // Continue to HTTP fallback
        }
      }

      // Standard HTTP download
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('HTTP Download failed. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      throw Exception('Critical error downloading from $url: $e');
    }
  }

  Future<String> _extractPdfText(File file) async {
    try {
      String text = await ReadPdfText.getPDFtext(file.path);
      if (text.isEmpty) {
         throw Exception('No text found in PDF (it might be an image-based PDF).');
      }
      return text;
    } catch (e) {
      throw Exception('Failed to parse PDF: $e');
    }
  }

  Future<String> _extractTxtText(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read text file: $e');
    }
  }
}
