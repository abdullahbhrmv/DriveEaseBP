class PlacePredictions {
  late String secondary_text;
  late String main_text;
  late String place_id;

  PlacePredictions({
    this.secondary_text = "",
    this.main_text = "",
    this.place_id = "",
  });

  PlacePredictions.fromJson(Map<String, dynamic> json) {
    place_id = json["place_id"] ?? "";
    main_text = json["structured_formatting"]?["main_text"] ?? "";
    secondary_text = json["structured_formatting"]?["secondary_text"] ?? "";
  }
}
