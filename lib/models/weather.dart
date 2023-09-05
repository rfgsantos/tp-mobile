import 'package:equatable/equatable.dart';

import 'base.dart';

class Weather extends Base {
  double? min_temp;
  double? max_temp;
  double? min_wind_speed;
  double? max_wind_speed;
  double? min_wind_direction;
  double? max_wind_direction;
  double? max_rain_risk;
  double? min_rain_risk;
  int? start_hour;
  int? end_hour;
  int? stage_id;
  DateTime? prediction_date;

  Weather(
      {this.min_temp,
      this.max_temp,
      this.min_wind_speed,
      this.max_wind_speed,
      this.min_wind_direction,
      this.max_wind_direction,
      this.max_rain_risk,
      this.min_rain_risk,
      this.start_hour,
      this.end_hour,
      this.stage_id,
      this.prediction_date});

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
      min_temp: json['min_temp'],
      max_temp: json['max_temp'],
      min_wind_speed: json['min_wind_speed'],
      max_wind_speed: json['max_wind_speed'],
      min_wind_direction: json['min_wind_direction'],
      max_wind_direction: json['max_wind_direction'],
      max_rain_risk: json['max_rain_risk'],
      min_rain_risk: json['min_rain_risk'],
      start_hour: json['start_hour'],
      end_hour: json['end_hour'],
      stage_id: json['stage_id'],
      prediction_date: json['prediction_date'] != null
          ? DateTime.parse(json['prediction_date'])
          : null);

  @override
  Map<String, dynamic> toJson() => {
        'min_temp': min_temp,
        'max_temp': max_temp,
        'min_wind_speed': min_wind_speed,
        'max_wind_speed': max_wind_speed,
        'min_wind_direction': min_wind_direction,
        'max_wind_direction': max_wind_direction,
        'max_rain_risk': max_rain_risk,
        'min_rain_risk': min_rain_risk,
        'start_hour': start_hour,
        'end_hour': end_hour,
        'stage_id': stage_id,
        'prediction_date': prediction_date.toString(),
        ...super.toJson()
      };

  @override
  List<Object?> get props => [
        min_temp,
        max_temp,
        min_wind_speed,
        max_wind_speed,
        min_wind_direction,
        max_wind_direction,
        max_rain_risk,
        min_rain_risk,
        start_hour,
        end_hour,
        stage_id,
        prediction_date
      ];
}
