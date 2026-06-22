import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TranscriptionResult {
  final String originalText;
  final String detectedLanguage;
  final String languageCode;

  TranscriptionResult({
    required this.originalText,
    required this.detectedLanguage,
    required this.languageCode,
  });
}

class TranscriptionService {
  TranscriptionService._internal();
  static final TranscriptionService instance = TranscriptionService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  String _lastLiveTranscription = '';

  /// Updates the live transcription collected during real-time speech recognition
  void setLiveTranscription(String text) {
    _lastLiveTranscription = text;
  }

  /// Performs translation and language detection on the live transcription
  Future<TranscriptionResult> transcribe(String audioFilePath) async {
    final text = _lastLiveTranscription.trim();
    if (text.isEmpty) {
      return TranscriptionResult(
        originalText: '',
        detectedLanguage: 'English',
        languageCode: 'en-US',
      );
    }

    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=${Uri.encodeComponent(text)}'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.length > 2) {
          final detectedCode = data[2] as String? ?? 'en';
          
          String langName = 'English';
          String langCode = 'en-US';
          
          final codeLower = detectedCode.toLowerCase();
          if (codeLower == 'hi') {
            langName = 'Hindi';
            langCode = 'hi-IN';
          } else if (codeLower == 'bn') {
            langName = 'Bengali';
            langCode = 'bn-IN';
          } else if (codeLower == 'en') {
            langName = 'English';
            langCode = 'en-US';
          } else {
            // Capitalize code as name or default
            langName = codeLower.toUpperCase();
            langCode = codeLower;
          }

          return TranscriptionResult(
            originalText: text,
            detectedLanguage: langName,
            languageCode: langCode,
          );
        }
      }
    } catch (e) {
      print('Error in transcription service language detection: $e');
    }

    // Default fallback
    return TranscriptionResult(
      originalText: text,
      detectedLanguage: 'English',
      languageCode: 'en-US',
    );
  }

  /// Translates non-English text to English
  Future<String> translateToEnglish(String text, String sourceLangCode) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return '';
    
    final cleanCode = sourceLangCode.split('-').first.toLowerCase();
    if (cleanCode == 'en') return cleanText;

    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=en&dt=t&q=${Uri.encodeComponent(cleanText)}'
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0] is List) {
          final segments = data[0] as List;
          return segments.map((s) => s[0] as String? ?? '').join('').trim();
        }
      }
    } catch (e) {
      print('Error in translateToEnglish: $e');
    }
    return '';
  }
}
