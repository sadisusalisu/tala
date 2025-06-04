import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class AudioService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Upload audio file to Supabase Storage
  Future<String?> uploadAudioFile({
    required File audioFile,
    required String fileName,
    required String language, // 'ha' or 'en'
  }) async {
    try {
      final String path = '$language/$fileName';
      
      await _supabase.storage
          .from('story-audio')
          .upload(path, audioFile);
      
      // Get public URL
      final String publicUrl = _supabase.storage
          .from('story-audio')
          .getPublicUrl(path);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading audio: $e');
      return null;
    }
  }
  
  // Upload image file
  Future<String?> uploadImageFile({
    required File imageFile,
    required String fileName,
  }) async {
    try {
      await _supabase.storage
          .from('story-images')
          .upload(fileName, imageFile);
      
      final String publicUrl = _supabase.storage
          .from('story-images')
          .getPublicUrl(fileName);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  // Add new story with media
  Future<bool> addStoryWithMedia({
    required Map<String, dynamic> storyData,
    File? audioFileHa,
    File? audioFileEn,
    File? imageFile,
  }) async {
    try {
      String? audioUrlHa;
      String? audioUrlEn;
      String? imageUrl;
      
      // Upload audio files if provided
      if (audioFileHa != null) {
        audioUrlHa = await uploadAudioFile(
          audioFile: audioFileHa,
          fileName: '${storyData['title_en'].toLowerCase().replaceAll(' ', '-')}-ha.mp3',
          language: 'ha',
        );
      }
      
      if (audioFileEn != null) {
        audioUrlEn = await uploadAudioFile(
          audioFile: audioFileEn,
          fileName: '${storyData['title_en'].toLowerCase().replaceAll(' ', '-')}-en.mp3',
          language: 'en',
        );
      }
      
      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await uploadImageFile(
          imageFile: imageFile,
          fileName: '${storyData['title_en'].toLowerCase().replaceAll(' ', '-')}.jpg',
        );
      }
      
      // Add URLs to story data
      final Map<String, dynamic> completeStoryData = {
        ...storyData,
        if (audioUrlHa != null) 'audio_url_ha': audioUrlHa,
        if (audioUrlEn != null) 'audio_url_en': audioUrlEn,
        if (imageUrl != null) 'image_url': imageUrl,
      };
      
      // Insert story into database
      await _supabase
          .from('stories')
          .insert(completeStoryData);
      
      return true;
    } catch (e) {
      print('Error adding story: $e');
      return false;
    }
  }
}