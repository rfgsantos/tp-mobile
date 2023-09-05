import 'package:equatable/equatable.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:tpmobile/models/weather.dart';

class StageSummary extends Equatable {
  int? id;
  int? order;
  GeoJSONPoint? starting_centroid;
  String? starting_marina;
  String? ending_marina;
  GeoJSONPoint? ending_centroid;
  double? time;
  double? distance;
  String? info;
  int? start_osm_id;
  int? end_osm_id;
  String? start_latlon_text;
  String? end_latlon_text;
  DateTime? start_time;
  DateTime? end_time;

  StageSummary(
      {this.starting_marina,
      this.ending_marina,
      this.time,
      this.distance,
      required this.starting_centroid,
      required this.ending_centroid,
      this.id,
      this.order,
      this.info,
      this.start_osm_id,
      this.end_osm_id,
      this.start_latlon_text,
      this.end_latlon_text,
      this.start_time,
      this.end_time});

  factory StageSummary.fromJson(Map<String, dynamic> json) => StageSummary(
      starting_marina: json['starting_marina'],
      ending_marina: json['ending_marina'],
      starting_centroid: json['starting_centroid'] != null
          ? GeoJSONPoint.fromMap(json['starting_centroid'])
          : null,
      ending_centroid: json['ending_centroid'] != null
          ? GeoJSONPoint.fromMap(json['ending_centroid'])
          : null,
      time: json['time'],
      distance: json['distance'],
      id: json['id'],
      order: json['order'],
      info: json['info'],
      start_latlon_text: json['start_latlon_text'],
      end_latlon_text: json['end_latlon_text'],
      start_osm_id: json['start_osm_id'],
      end_osm_id: json['end_osm_id'],
      start_time: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      end_time:
          json['end_time'] != null ? DateTime.parse(json['end_time']) : null);

  Map<String, dynamic> toJson() => {
        'id': id,
        'distance': distance,
        'starting_marina': starting_marina,
        'ending_marina': ending_marina,
        'starting_centroid': starting_centroid?.toMap(),
        'ending_centroid': ending_centroid?.toMap(),
        'time': time,
        'info': info,
        'order': order,
        'start_latlon_text': start_latlon_text,
        'end_latlon_text': end_latlon_text,
        'start_osm_id': start_osm_id,
        'end_osm_id': end_osm_id,
        'start_time': start_time?.toString(),
        'end_time': end_time?.toString()
      };

  @override
  String toString() => """Id: $id
      order: $order
      start_osm_id: $starting_centroid
      starting_marina: $starting_marina
      end_osm_id: $ending_centroid
      ending_marina: $ending_marina
      time: $time
      info: $info
      end_osm_id: $end_osm_id
      start_osm_id: $start_osm_id
      start_latlon_text: $start_latlon_text
      end_latlon_text: $end_latlon_text
      end_time: ${end_time.toString()}
      start_time: ${start_time.toString()}
      """;

  @override
  List<Object?> get props => [
        id,
        order,
        starting_marina,
        ending_marina,
        ending_centroid,
        starting_centroid,
        end_latlon_text,
        start_latlon_text,
        end_osm_id,
        start_osm_id,
        info
      ];
}

class StageSummaryFullWrapper extends Equatable {
  final StageSummaryWrapper summary;
  final List<StagePointsSummary> points;

  const StageSummaryFullWrapper({required this.summary, required this.points});

  @override
  List<Object?> get props => [summary, points];

  factory StageSummaryFullWrapper.fromJson(Map<String, dynamic> json) =>
      StageSummaryFullWrapper(
          summary: StageSummaryWrapper.fromJson(json['summary']),
          points: (json['points'] as List)
              .map((e) => StagePointsSummary.fromJson(e))
              .toList());

  Map<String, dynamic> toJson() => {
        'summary': summary.toJson(),
        'points': points.map((e) => e.toJson()).toList()
      };
}

class StagePointsSummary extends Equatable {
  final int firstindex;
  final int secondindex;
  final String latlontext;
  final double distance;
  final GeoJSONPoint point;

  const StagePointsSummary(
      {required this.firstindex,
      required this.secondindex,
      required this.latlontext,
      required this.distance,
      required this.point});

  @override
  List<Object?> get props => [firstindex, secondindex, latlontext, distance];

  factory StagePointsSummary.fromJson(Map<String, dynamic> json) =>
      StagePointsSummary(
          firstindex: json['firstindex'],
          secondindex: json['secondindex'],
          latlontext: json['latlontext'],
          distance: json['distance'],
          point: GeoJSONPoint.fromMap(json['point']));

  Map<String, dynamic> toJson() => {
        'firstindex': firstindex,
        'secondindex': secondindex,
        'latlontext': latlontext,
        'distance': distance,
        'point': point.toMap()
      };
}

class StageSummaryWrapper extends Equatable {
  List<Weather>? weather;
  StageSummary? summary;

  StageSummaryWrapper({this.summary, this.weather});

  factory StageSummaryWrapper.fromJson(Map<String, dynamic> json) =>
      StageSummaryWrapper(
          weather: (json['weather'] as List)
              .map((e) => Weather.fromJson(e))
              .toList(),
          summary: StageSummary.fromJson(json['summary']));

  Map<String, dynamic> toJson() => {
        'weather': weather?.map((e) => e.toJson()).toList(),
        'summary': summary?.toJson()
      };

  @override
  List<Object?> get props => [weather, summary];
}

class StageBounds extends Equatable {
  final GeoJSONPoint northeast;
  final GeoJSONPoint southwest;

  const StageBounds({required this.northeast, required this.southwest});

  factory StageBounds.fromJson(Map<String, dynamic> json) => StageBounds(
      northeast: GeoJSONPoint.fromMap(json['northeast']),
      southwest: GeoJSONPoint.fromMap(json['southwest']));

  Map<String, dynamic> toJson() =>
      {'southwest': southwest.toMap(), 'northeast': northeast.toMap()};

  @override
  List<Object?> get props => [northeast, southwest];
}
