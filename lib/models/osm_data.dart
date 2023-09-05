class OSMDataCentroid {
  int osm_id;
  String name;
  double? way_area;
  double y;
  double x;

  OSMDataCentroid(
      {required this.osm_id,
      required this.name,
      required this.y,
      required this.x,
      this.way_area});

  factory OSMDataCentroid.fromJson(Map<String, dynamic> json) {
    return OSMDataCentroid(
        osm_id: json['osm_id'],
        name: json['name'],
        way_area: json['way_area'],
        y: json['y'],
        x: json['x']);
  }

  Map<String, dynamic> toJson() {
    return {
      "osm_id": osm_id,
      "name": name,
      "way_area": way_area,
      "y": y,
      "x": x
    };
  }
}
