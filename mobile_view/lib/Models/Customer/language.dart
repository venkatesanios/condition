class LanguageList
{
  LanguageList({
    this.languageId = 0,
    this.languageName = '',
    this.active = '',
  });

  int languageId;
  String languageName, active;

  factory LanguageList.fromJson(Map<String, dynamic> json) => LanguageList(
    languageId: json['languageId'],
    languageName: json['languageName'],
    active: json['active'],
  );

  Map<String, dynamic> toJson() => {
    'languageId': languageId,
    'languageName': languageName,
    'active': active,
  };
}