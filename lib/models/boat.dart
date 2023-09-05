import 'package:equatable/equatable.dart';

class Boat extends Equatable {
  String model;
  String year;
  String brand;
  String? image;
  bool? auxiliary;
  Specification? specification;
  MotorSpecification? motor_specification;

  Boat(
      {required this.model,
      required this.year,
      required this.brand,
      this.image,
      this.auxiliary,
      this.specification,
      this.motor_specification});

  factory Boat.fromJson(Map<String, dynamic> json) => Boat(
      model: json['model'],
      year: json['year'],
      brand: json['year'],
      image: json['image'],
      auxiliary: json['auxiliary'],
      specification: Specification.fromJson(json['specification']),
      motor_specification:
          MotorSpecification.fromJson(json['motor_specification']));

  Map<String, dynamic> toJson() => {
        'model': model,
        'year': year,
        'brand': brand,
        'image': image,
        'auxiliary': auxiliary,
        'specification': specification?.toJson(),
        'motor_specification': motor_specification?.toJson()
      };

  @override
  List<Object?> get props => [
        model,
        year,
        brand,
        image,
        auxiliary,
        specification,
        motor_specification
      ];
}

class Specification extends Equatable {
  int? total_length;
  int? hull_length;
  int? water_line_length;
  int? water_deposit;
  int? ballast;
  int? draft;
  int? beam;
  int? n_cabins;
  int? sail_area;
  String? mast_type;
  int? mast_height;
  int? max_cargo;
  int? mean_speed;
  int? category;
  int? width;
  int? capacity;
  int? weight;

  Specification(
      {this.total_length,
      this.hull_length,
      this.water_line_length,
      this.water_deposit,
      this.ballast,
      this.draft,
      this.beam,
      this.n_cabins,
      this.sail_area,
      this.mast_type,
      this.mast_height,
      this.max_cargo,
      this.mean_speed,
      this.category,
      this.width,
      this.capacity,
      this.weight});

  factory Specification.fromJson(Map<String, dynamic> json) => Specification(
      total_length: json['total_length'],
      hull_length: json['hull_length'],
      water_line_length: json['water_line_length'],
      water_deposit: json['water_deposit'],
      ballast: json['ballast'],
      draft: json['draft'],
      beam: json['beam'],
      n_cabins: json['n_cabins'],
      sail_area: json['sail_area'],
      mast_type: json['mast_type'],
      mast_height: json['mast_height'],
      max_cargo: json['max_cargo'],
      mean_speed: json['mean_speed'],
      category: json['category'],
      width: json['width'],
      capacity: json['capacity'],
      weight: json['weight']);

  Map<String, dynamic> toJson() => {
        'total_length': total_length,
        'hull_length': hull_length,
        'water_line_length': water_line_length,
        'water_deposit': water_deposit,
        'ballast': ballast,
        'draft': draft,
        'beam': beam,
        'n_cabins': n_cabins,
        'sail_area': sail_area,
        'mast_type': mast_type,
        'mast_height': mast_height,
        'max_cargo': max_cargo,
        'mean_speed': mean_speed,
        'category': category,
        'width': width,
        'capacity': capacity,
        'weight': weight
      };

  @override
  List<Object?> get props => [
        total_length,
        hull_length,
        water_line_length,
        water_deposit,
        ballast,
        draft,
        beam,
        n_cabins,
        sail_area,
        mast_type,
        mast_height,
        max_cargo,
        mean_speed,
        category,
        width,
        capacity,
        weight
      ];
}

class MotorSpecification extends Equatable {
  int? model;
  int? horse_power;
  String? brand;
  int? deposit;

  MotorSpecification(
      {required this.model,
      required this.horse_power,
      required this.brand,
      required this.deposit});

  factory MotorSpecification.fromJson(Map<String, dynamic> json) =>
      MotorSpecification(
          model: json['model'],
          horse_power: json['horse_power'],
          brand: json['brand'],
          deposit: json['deposit']);

  Map<String, dynamic> toJson() => {
        'model': model,
        'horse_power': horse_power,
        'brand': brand,
        'deposit': deposit
      };

  @override
  List<Object?> get props => [brand, model, deposit, horse_power];
}
