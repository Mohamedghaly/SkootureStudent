import 'package:eschool/data/models/childUserDetails.dart';
import 'package:eschool/data/models/classSection.dart';
import 'package:eschool/data/models/guardian.dart';
import 'package:eschool/data/models/school.dart';
import 'package:eschool/data/models/studentProfileExtraDetails.dart';


class Student {
  final int? id;
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? mobile;
  final String? gender;
  final String? image;
  final String? dob;
  final String? currentAddress;
  final String? permanentAddress;
  final int? status;
  final String? fcmId;
  final int? schoolId;
  final String? createdAt;
  final String? updatedAt;
  final ClassSection? classSection;
  final Guardian? guardian;
  final School? school;
  final int? sessionYearId;
  final int? rollNumber;
  final String? admissionNo;
  final String? admissionDate;
  final List<StudentProfileExtraDetails>? studentProfileExtraDetails;
  final ChildUserDetails? childUserDetails;
  final String? password;

  Student({
    this.id,
    this.firstName,
    this.userId,
    this.lastName,
    this.mobile,
    this.gender,
    this.image,
    this.dob,
    this.currentAddress,
    this.permanentAddress,
    this.status,
    this.fcmId,
    this.schoolId,
    this.createdAt,
    this.updatedAt,
    this.classSection,
    this.guardian,
    this.school,
    this.admissionDate,
    this.admissionNo,
    this.rollNumber,
    this.sessionYearId,
    this.studentProfileExtraDetails,
    this.childUserDetails,
    this.password,
  });

  Student copyWith({
    int? id,
    String? firstName,
    int? userId,
    String? lastName,
    String? mobile,
    String? gender,
    String? image,
    String? dob,
    String? currentAddress,
    String? permanentAddress,
    int? status,
    String? fcmId,
    int? schoolId,
    String? createdAt,
    String? updatedAt,
    ClassSection? classSection,
    Guardian? guardian,
    School? school,
    int? sessionYearId,
    int? rollNumber,
    String? admissionNo,
    String? admissionDate,
    List<StudentProfileExtraDetails>? studentProfileExtraDetails,
    ChildUserDetails? childUserDetails,
    String? password,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      userId: userId ?? this.userId,
      lastName: lastName ?? this.lastName,
      mobile: mobile ?? this.mobile,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      dob: dob ?? this.dob,
      currentAddress: currentAddress ?? this.currentAddress,
      permanentAddress: permanentAddress ?? this.permanentAddress,
      status: status ?? this.status,
      fcmId: fcmId ?? this.fcmId,
      schoolId: schoolId ?? this.schoolId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      classSection: classSection ?? this.classSection,
      guardian: guardian ?? this.guardian,
      school: school ?? this.school,
      sessionYearId: sessionYearId ?? this.sessionYearId,
      rollNumber: rollNumber ?? this.rollNumber,
      admissionNo: admissionNo ?? this.admissionNo,
      admissionDate: admissionDate ?? this.admissionDate,
      studentProfileExtraDetails:
          studentProfileExtraDetails ?? this.studentProfileExtraDetails,
      childUserDetails: childUserDetails ?? this.childUserDetails,
      password: password ?? this.password,
    );
  }

  Student.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int?,
        userId = json['userId'] as int?,
        firstName = json['firstName'] as String?,
        lastName = json['lastName'] as String?,
        mobile = json['mobile'] as String?,
        gender = json['gender'] as String?,
        image = json['image'] as String?,
        dob = json['dob'] as String?,
        currentAddress = json['currentAddress'] as String?,
        permanentAddress = json['permanentAddress'] as String?,
        status = json['status'] as int?,
        fcmId = json['fcmId'] as String?,
        schoolId = json['schoolId'] as int?,
        createdAt = json['createdAt'] as String?,
        updatedAt = json['updatedAt'] as String?,
        classSection = json['classSection'] != null
            ? ClassSection.fromJson(
                Map<String, dynamic>.from(json['classSection']))
            : null,
        guardian = json['guardian'] != null
            ? Guardian.fromJson(Map<String, dynamic>.from(json['guardian']))
            : null,
        school = json['school'] != null
            ? School.fromJson(Map<String, dynamic>.from(json['school']))
            : null,
        sessionYearId = json['sessionYearId'] as int?,
        rollNumber = json['rollNumber'] as int?,
        admissionNo = json['admissionNo'] as String?,
        admissionDate = json['admissionDate'] as String?,
        studentProfileExtraDetails =
            (json['studentProfileExtraDetails'] as List<dynamic>?)
                ?.map((e) => StudentProfileExtraDetails.fromJson(
                    Map<String, dynamic>.from(e)))
                .toList(),
        childUserDetails = json['childUserDetails'] != null
            ? ChildUserDetails.fromJson(
                Map<String, dynamic>.from(json['childUserDetails']))
            : null,
        password = json['password'] as String?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'gender': gender,
        'image': image,
        'dob': dob,
        'currentAddress': currentAddress,
        'permanentAddress': permanentAddress,
        'status': status,
        'fcmId': fcmId,
        'schoolId': schoolId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'classSection': classSection?.toJson(),
        'guardian': guardian?.toJson(),
        'school': school?.toJson(),
        'sessionYearId': sessionYearId,
        'rollNumber': rollNumber,
        'admissionNo': admissionNo,
        'admissionDate': admissionDate,
        'studentProfileExtraDetails':
            studentProfileExtraDetails?.map((e) => e.toJson()).toList(),
        'childUserDetails': childUserDetails?.toJson(),
        'password': password,
      };

        String getFullName() {
        return "$firstName $lastName";
        }

        @override
        String toString() {
         return '$firstName $lastName - ${classSection?.classDetails?.name}${classSection?.section?.name}';
        }
}