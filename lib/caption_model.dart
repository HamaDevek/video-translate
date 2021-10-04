import 'dart:convert';

class CaptionModel {
  CaptionModel({
    required this.text,
    required this.start,
    required this.duration,
  });

  final String text;
  final double start;
  final double duration;

  factory CaptionModel.fromJson(str) => CaptionModel.fromMap(str);

  String toJson() => json.encode(toMap());

  factory CaptionModel.fromMap(Map<String, dynamic> json) => CaptionModel(
        text: json["text"],
        start: json["start"].toDouble(),
        duration: json["duration"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "text": text,
        "start": start,
        "duration": duration,
      };
}
