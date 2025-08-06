import 'dart:convert';

MacModel macModelFromJson(String str) => MacModel.fromJson(json.decode(str));

String macModelToJson(MacModel data) => json.encode(data.toJson());

class MacModel {
  final bool? status;
  final String? message;
  final List<Mac> data;

  MacModel({
    this.status,
    this.message,
    required this.data,
  });

  factory MacModel.fromJson(Map<String, dynamic> json) => MacModel(
        status: json["status"],
        message: json["message"],
        data: List<Mac>.from(json["data"].map((x) => Mac.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Mac {
  final int id;
  final String macAddress;
  final String model;

  Mac({
    required this.id,
    required this.macAddress,
    required this.model,
  });

  factory Mac.fromJson(Map<String, dynamic> json) => Mac(
        id: json["id"],
        macAddress: json["mac_address"],
        model: json["model"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "mac_address": macAddress,
        "model": model,
      };
}
