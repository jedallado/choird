import 'package:shared_preferences/shared_preferences.dart';

import '../models/song_content_font_size.dart';

class SongContentPreferences {
  static const _fontSizeKey = 'song_content_font_size';

  Future<SongContentFontSize> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return SongContentFontSize.fromName(prefs.getString(_fontSizeKey));
  }

  Future<void> setFontSize(SongContentFontSize fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontSizeKey, fontSize.name);
  }
}
