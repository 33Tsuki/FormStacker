import 'dart:convert';

class FormResponse {
  final int? id;
  final String name;
  final String email;
  final DateTime dob;
  final int age;
  final String gender;
  final int yearsOfExperience;
  final int rating;
  final bool agreed;
  final String? photoPath;
  final String? resumePath;
  final List<String> languages;
  final int heightFeet;
  final int heightInches;
  final double weight;
  final bool synced;
  final String? firestoreId;
  final DateTime? createdAt;

  FormResponse({
    this.id,
    required this.name,
    required this.email,
    required this.dob,
    required this.age,
    required this.gender,
    required this.yearsOfExperience,
    required this.rating,
    required this.agreed,
    this.photoPath,
    this.resumePath,
    this.languages = const [],
    this.heightFeet = 0,
    this.heightInches = 0,
    this.weight = 0.0,
    this.synced = false,
    this.firestoreId,
    this.createdAt,
  });

  // Convert FormResponse to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'dob': dob.toIso8601String(),
      'age': age,
      'gender': gender,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'agreed': agreed ? 1 : 0,
      'photoPath': photoPath,
      'resumePath': resumePath,
      'languages': jsonEncode(languages),
      'heightFeet': heightFeet,
      'heightInches': heightInches,
      'weight': weight,
      'synced': synced ? 1 : 0,
      'firestoreId': firestoreId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Create FormResponse from database Map
  factory FormResponse.fromMap(Map<String, dynamic> map) {
    return FormResponse(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String? ?? '',
      dob: DateTime.parse(map['dob'] as String),
      age: map['age'] as int,
      gender: map['gender'] as String,
      yearsOfExperience: map['yearsOfExperience'] as int? ?? 0,
      rating: map['rating'] as int,
      agreed: (map['agreed'] as int?) == 1,
      photoPath: map['photoPath'] as String?,
      resumePath: map['resumePath'] as String?,
      languages: map['languages'] != null
          ? List<String>.from(
              jsonDecode(map['languages'] as String) as List<dynamic>,
            )
          : const [],
      heightFeet: map['heightFeet'] as int? ?? 0,
      heightInches: map['heightInches'] as int? ?? 0,
      weight: map['weight'] is num
          ? (map['weight'] as num).toDouble()
          : double.tryParse(map['weight']?.toString() ?? '') ?? 0.0,
      synced: (map['synced'] as int?) == 1,
      firestoreId: map['firestoreId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
    );
  }

  // Create a copy with modified fields
  FormResponse copyWith({
    int? id,
    String? name,
    String? email,
    DateTime? dob,
    int? age,
    String? gender,
    int? yearsOfExperience,
    int? rating,
    bool? agreed,
    String? photoPath,
    String? resumePath,
    List<String>? languages,
    int? heightFeet,
    int? heightInches,
    double? weight,
    bool? synced,
    String? firestoreId,
    DateTime? createdAt,
  }) {
    return FormResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      agreed: agreed ?? this.agreed,
      photoPath: photoPath ?? this.photoPath,
      resumePath: resumePath ?? this.resumePath,
      languages: languages ?? this.languages,
      heightFeet: heightFeet ?? this.heightFeet,
      heightInches: heightInches ?? this.heightInches,
      weight: weight ?? this.weight,
      synced: synced ?? this.synced,
      firestoreId: firestoreId ?? this.firestoreId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'FormResponse(id: $id, name: $name, dob: $dob, age: $age, gender: $gender, rating: $rating, agreed: $agreed, photoPath: $photoPath, resumePath: $resumePath, languages: $languages, heightFeet: $heightFeet, heightInches: $heightInches, weight: $weight, createdAt: $createdAt)';
  }
}
