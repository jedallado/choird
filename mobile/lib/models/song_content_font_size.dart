enum SongContentFontSize {
  s(14),
  m(16),
  l(18),
  xl(20);

  const SongContentFontSize(this.fontSize);

  final double fontSize;

  String get menuLabel => switch (this) {
    SongContentFontSize.s => 'Small',
    SongContentFontSize.m => 'Medium',
    SongContentFontSize.l => 'Large',
    SongContentFontSize.xl => 'Extra Large',
  };

  bool get canDecrease => index > 0;

  bool get canIncrease => index < SongContentFontSize.values.length - 1;

  SongContentFontSize get smaller {
    if (!canDecrease) {
      return this;
    }

    return SongContentFontSize.values[index - 1];
  }

  SongContentFontSize get larger {
    if (!canIncrease) {
      return this;
    }

    return SongContentFontSize.values[index + 1];
  }

  static SongContentFontSize fromName(String? name) {
    return SongContentFontSize.values.firstWhere(
      (size) => size.name == name,
      orElse: () => SongContentFontSize.m,
    );
  }
}
