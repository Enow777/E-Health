import 'package:flutter/material.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.initials,
    required this.specialty,
    required this.clinic,
    required this.distance,
    required this.rating,
    required this.nextAvailable,
    required this.experience,
    required this.about,
    required this.languages,
    this.ratingCount = 0,
  });

  final String id;
  final String name;
  final String initials;
  final String specialty;
  final String clinic;
  final String distance;
  final double rating;
  final int ratingCount;
  final String nextAvailable;
  final String experience;
  final String about;
  final String languages;

  bool get hasRatings => ratingCount > 0;

  factory Doctor.fromMap(String id, Map<String, dynamic> data) {
    final name = _string(data['fullName'] ?? data['name'], 'Unknown doctor');
    return Doctor(
      id: id,
      name: name,
      initials: _string(data['initials'], _initialsFromName(name)),
      specialty: _string(data['speciality'] ?? data['specialty'], 'General'),
      clinic: _string(data['clinic'], 'Nkap Health Clinic'),
      distance: _string(data['distance'], 'Nearby'),
      rating: _double(data['rating'], 0.0),
      ratingCount: (data['ratingCount'] as int?) ?? 0,
      nextAvailable: _string(data['nextAvailable'], 'Available today'),
      experience: _string(data['experience'], '5 years'),
      about: _string(
        data['about'],
        'Provides patient-centred care through Nkap Health.',
      ),
      languages: _string(data['languages'], 'English'),
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': name,
    'initials': initials,
    'speciality': specialty,
    'clinic': clinic,
    'distance': distance,
    'rating': rating,
    'ratingCount': ratingCount,
    'nextAvailable': nextAvailable,
    'experience': experience,
    'about': about,
    'languages': languages,
  };
}

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.schedule,
    required this.duration,
    required this.color,
  });

  final String id;
  final String name;
  final String dosage;
  final String schedule;
  final String duration;
  final Color color;

  factory Medication.fromMap(String id, Map<String, dynamic> data) {
    return Medication(
      id: id,
      name: _string(data['medicationName'] ?? data['name'], 'Medication'),
      dosage: _string(data['dosage'], 'As prescribed'),
      schedule: _string(data['schedule'], 'Follow schedule'),
      duration: _string(data['duration'], 'Active'),
      color: Color(_int(data['color'], 0xFFE2F1EE)),
    );
  }

  Map<String, dynamic> toMap({String? patientId, String? doctorId}) => {
    if (patientId != null) 'patientId': patientId,
    if (doctorId != null) 'doctorId': doctorId,
    'medicationName': name,
    'dosage': dosage,
    'schedule': schedule,
    'duration': duration,
    'color': color.toARGB32(),
  };
}

class MedicalRecord {
  const MedicalRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.icon,
    required this.summary,
    required this.provider,
    this.fileUrl,
  });

  final String id;
  final String type;
  final String title;
  final String date;
  final IconData icon;
  final String summary;
  final String provider;
  final String? fileUrl;

  factory MedicalRecord.fromMap(String id, Map<String, dynamic> data) {
    final type = _string(data['recordType'] ?? data['type'], 'Record');
    return MedicalRecord(
      id: id,
      type: type,
      title: _string(data['title'], 'Medical record'),
      date: _string(data['date'], 'Recently'),
      icon: iconForRecordType(type),
      summary: _string(data['summary'], 'No summary has been added.'),
      provider: _string(data['provider'], 'Nkap Health'),
      fileUrl: data['fileUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap({String? patientId}) => {
    if (patientId != null) 'patientId': patientId,
    'recordType': type,
    'title': title,
    'date': date,
    'summary': summary,
    'provider': provider,
    if (fileUrl != null) 'fileUrl': fileUrl,
  };
}

class Appointment {
  const Appointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
    this.patientId = '',
    this.patientName = '',
    this.roomUrl = '',
    this.isRated = false,
    this.urgency = 'normal',
    this.callActive = false,
    this.patientInCall = false,
  });

  final String id;
  final Doctor doctor;
  final String date;
  final String time;
  final String type;
  final String status;
  final String patientId;
  final String patientName;
  final String roomUrl;
  final bool isRated;
  final String urgency;
  final bool callActive;
  final bool patientInCall;

  String get videoRoomUrl =>
      roomUrl.isNotEmpty ? roomUrl : 'https://meet.jit.si/NkapHealth-$id';

  /// Parses the stored ISO date ("2026-06-15") + time ("9:30 AM") into a
  /// DateTime. Returns null for legacy display-string dates that can't be parsed.
  DateTime? get scheduledAt {
    try {
      final d = DateTime.parse(date); // requires "YYYY-MM-DD"
      final t = time.trim().toUpperCase();
      final isPm = t.contains('PM');
      final digits = t.replaceAll(RegExp(r'[^0-9:]'), '');
      final seg = digits.split(':');
      var hour = int.parse(seg[0]);
      final minute = seg.length > 1 ? int.parse(seg[1]) : 0;
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
      return DateTime(d.year, d.month, d.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  /// True when the current time is within the call window:
  /// 15 minutes before the appointment up to 2 hours after.
  /// Returns true for legacy appointments whose date can't be parsed (no restriction).
  bool get isInCallWindow {
    final dt = scheduledAt;
    if (dt == null) return true;
    final now = DateTime.now();
    return now.isAfter(dt.subtract(const Duration(minutes: 15))) &&
        now.isBefore(dt.add(const Duration(hours: 2)));
  }

  /// Display-friendly date. Formats ISO dates ("2026-06-15") as "Mon, 15 Jun".
  /// Falls back to the raw stored value for legacy display-string dates.
  String get formattedDate {
    try {
      final d = DateTime.parse(date);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
    } catch (_) {
      return date;
    }
  }

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    final doctorData = Map<String, dynamic>.from(
      data['doctor'] as Map? ?? <String, dynamic>{},
    );
    return Appointment(
      id: id,
      doctor: Doctor.fromMap(_string(data['doctorId'], 'doctor'), doctorData),
      date: _string(data['date'], 'Today'),
      time: _string(data['time'], 'Pending'),
      type: _string(data['consultationType'] ?? data['type'], 'Clinic visit'),
      status: _string(data['status'], 'upcoming'),
      patientId: _string(data['patientId'], ''),
      patientName: _string(data['patientName'], 'Patient'),
      roomUrl: _string(data['roomUrl'], ''),
      isRated: data['isRated'] == true,
      urgency: _string(data['urgency'], 'normal'),
      callActive: data['callActive'] == true,
      patientInCall: data['patientInCall'] == true,
    );
  }

  Map<String, dynamic> toMap({required String patientId}) => {
    'patientId': patientId,
    'doctorId': doctor.id,
    'doctor': doctor.toMap(),
    'date': date,
    'time': time,
    'consultationType': type,
    'status': status,
    'urgency': urgency,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.patientCode,
    this.photoUrl = '',
  });

  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String patientCode;
  final String photoUrl;

  String get initials => _initialsFromName(fullName);

  factory PatientProfile.fromMap(String id, Map<String, dynamic> data) {
    return PatientProfile(
      id: id,
      fullName: _string(data['fullName'], 'Nkap Health Patient'),
      email: _string(data['email'], ''),
      phoneNumber: _string(data['phoneNumber'], ''),
      patientCode: _string(data['patientCode'], 'NKH-${id.substring(0, 5)}'),
      photoUrl: _string(data['photoUrl'], ''),
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'patientCode': patientCode,
    if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
  };
}

class HealthNotification {
  const HealthNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });

  final String id;
  final String category;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  IconData get icon {
    return switch (category.toLowerCase()) {
      'medication' => Icons.medication_outlined,
      'record' => Icons.description_outlined,
      _ => Icons.calendar_today_outlined,
    };
  }

  factory HealthNotification.fromMap(String id, Map<String, dynamic> data) {
    return HealthNotification(
      id: id,
      category: _string(data['category'], 'appointment'),
      title: _string(data['title'], 'Notification'),
      message: _string(data['message'], ''),
      time: _string(data['time'], 'Now'),
      isRead: data['isRead'] == true,
    );
  }

  Map<String, dynamic> toMap({String? patientId}) => {
    if (patientId != null) 'patientId': patientId,
    'category': category,
    'title': title,
    'message': message,
    'time': time,
    'isRead': isRead,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

// ── RecordShare ───────────────────────────────────────────────────────────────

class RecordShare {
  const RecordShare({
    required this.id,
    required this.recordId,
    required this.recordTitle,
    required this.doctorId,
    required this.doctorName,
    required this.createdAt,
  });

  final String id;
  final String recordId;
  final String recordTitle;
  final String doctorId;
  final String doctorName;
  final String createdAt;

  factory RecordShare.fromMap(String id, Map<String, dynamic> data) =>
      RecordShare(
        id: id,
        recordId: _string(data['recordId'], ''),
        recordTitle: _string(data['recordTitle'], 'Record'),
        doctorId: _string(data['doctorId'], ''),
        doctorName: _string(data['doctorName'], 'Doctor'),
        createdAt: _string(data['createdAt'], ''),
      );
}

// ── RecordAccess ─────────────────────────────────────────────────────────────

class RecordAccess {
  const RecordAccess({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.patientName,
    required this.status,
    required this.updatedAt,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String patientName;
  final String status; // 'granted' | 'blocked' | 'requested'
  final String updatedAt;

  bool get isGranted   => status == 'granted';
  bool get isBlocked   => status == 'blocked';
  bool get isRequested => status == 'requested';

  factory RecordAccess.fromMap(String id, Map<String, dynamic> data) =>
      RecordAccess(
        id: id,
        patientId: _string(data['patientId'], ''),
        doctorId: _string(data['doctorId'], ''),
        doctorName: _string(data['doctorName'], 'Doctor'),
        patientName: _string(data['patientName'], 'Patient'),
        status: _string(data['status'], 'granted'),
        updatedAt: _string(data['updatedAt'], ''),
      );
}

// ── DoctorProfile ─────────────────────────────────────────────────────────────

class DoctorProfile {
  const DoctorProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.specialties,
    required this.clinic,
    required this.phoneNumber,
    required this.about,
    required this.languages,
    required this.experience,
    this.age = '',
    this.sex = '',
    this.photoUrl = '',
    this.rating = 0.0,
    this.ratingCount = 0,
    this.nextAvailable = 'Available today',
    this.isAvailable = true,
    this.setupComplete = false,
    this.weeklySchedule = const {},
    this.hospitalId = '',
    this.hospitalName = '',
    this.approvalStatus = '',
  });

  final String id;
  final String fullName;
  final String email;
  final List<String> specialties;
  final String clinic;
  final String phoneNumber;
  final String about;
  final String languages;
  final String experience;
  final String age;
  final String sex;
  final String photoUrl;
  final double rating;
  final int ratingCount;
  final String nextAvailable;
  final bool isAvailable;
  final bool setupComplete;
  final Map<String, dynamic> weeklySchedule;
  // Hospital affiliation: '' = independent, 'pending'/'approved'/'rejected' = under a hospital
  final String hospitalId;
  final String hospitalName;
  final String approvalStatus;

  /// Joined specialties string for backwards-compatible reads and display.
  String get specialty =>
      specialties.isNotEmpty ? specialties.join(', ') : 'General';

  String get initials => _initialsFromName(fullName);

  factory DoctorProfile.fromMap(String id, Map<String, dynamic> data) {
    // Support both list (new) and single string (legacy profiles)
    List<String> specialties;
    final raw = data['specialties'];
    if (raw is List && raw.isNotEmpty) {
      specialties = raw.cast<String>();
    } else {
      final s = _string(data['specialty'] ?? data['speciality'], '');
      specialties = s.isNotEmpty ? [s] : [];
    }
    return DoctorProfile(
      id: id,
      fullName: _string(data['fullName'], 'Doctor'),
      email: _string(data['email'], ''),
      specialties: specialties,
      clinic: _string(data['clinic'], ''),
      phoneNumber: _string(data['phoneNumber'], ''),
      about: _string(data['about'], ''),
      languages: _string(data['languages'], 'English'),
      experience: _string(data['experience'], ''),
      age: _string(data['age'], ''),
      sex: _string(data['sex'], ''),
      photoUrl: _string(data['photoUrl'], ''),
      rating: _double(data['rating'], 0.0),
      ratingCount: (data['ratingCount'] as int?) ?? 0,
      nextAvailable: _string(data['nextAvailable'], 'Available today'),
      isAvailable: data['isAvailable'] != false,
      setupComplete: data['setupComplete'] == true,
      weeklySchedule: Map<String, dynamic>.from(
          data['weeklySchedule'] as Map? ?? {}),
      hospitalId: _string(data['hospitalId'], ''),
      hospitalName: _string(data['hospitalName'], ''),
      approvalStatus: _string(data['approvalStatus'], ''),
    );
  }

  Map<String, dynamic> toMap() => {
    'fullName': fullName,
    'email': email,
    'specialties': specialties,
    'specialty': specialty,
    'speciality': specialty,
    'clinic': clinic,
    'phoneNumber': phoneNumber,
    'about': about,
    'languages': languages,
    'experience': experience,
    'age': age,
    'sex': sex,
    if (photoUrl.isNotEmpty) 'photoUrl': photoUrl,
    'rating': rating,
    'ratingCount': ratingCount,
    'nextAvailable': nextAvailable,
    'isAvailable': isAvailable,
    'setupComplete': setupComplete,
    'weeklySchedule': weeklySchedule,
    'initials': initials,
    'distance': 'Nearby',
    if (hospitalId.isNotEmpty) 'hospitalId': hospitalId,
    if (hospitalName.isNotEmpty) 'hospitalName': hospitalName,
    if (approvalStatus.isNotEmpty) 'approvalStatus': approvalStatus,
  };

  Doctor toDoctor() => Doctor(
    id: id,
    name: fullName,
    initials: initials,
    specialty: specialty,
    clinic: clinic.isNotEmpty ? clinic : 'Nkap Health Clinic',
    distance: 'Nearby',
    rating: rating,
    nextAvailable: nextAvailable,
    experience: experience.isNotEmpty ? experience : 'Experienced',
    about: about.isNotEmpty ? about : 'Committed to providing quality patient care.',
    languages: languages,
  );

  DoctorProfile copyWith({
    String? fullName,
    List<String>? specialties,
    String? clinic,
    String? phoneNumber,
    String? about,
    String? languages,
    String? experience,
    String? age,
    String? sex,
    String? photoUrl,
    String? nextAvailable,
    bool? isAvailable,
    bool? setupComplete,
    Map<String, dynamic>? weeklySchedule,
    String? hospitalId,
    String? hospitalName,
    String? approvalStatus,
  }) {
    return DoctorProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      specialties: specialties ?? this.specialties,
      clinic: clinic ?? this.clinic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      about: about ?? this.about,
      languages: languages ?? this.languages,
      experience: experience ?? this.experience,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating,
      ratingCount: ratingCount,
      nextAvailable: nextAvailable ?? this.nextAvailable,
      isAvailable: isAvailable ?? this.isAvailable,
      setupComplete: setupComplete ?? this.setupComplete,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      hospitalId: hospitalId ?? this.hospitalId,
      hospitalName: hospitalName ?? this.hospitalName,
      approvalStatus: approvalStatus ?? this.approvalStatus,
    );
  }
}

// ── Chat ──────────────────────────────────────────────────────────────────────

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    this.lastMessage = '',
    this.lastMessageTime,
    this.lastSenderId = '',
    this.patientUnread = 0,
    this.doctorUnread = 0,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String doctorName;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;
  final int patientUnread;
  final int doctorUnread;

  int unreadFor(String uid) =>
      uid == patientId ? patientUnread : doctorUnread;

  factory ChatConversation.fromMap(String id, Map<String, dynamic> data) {
    return ChatConversation(
      id: id,
      patientId: _string(data['patientId'], ''),
      doctorId: _string(data['doctorId'], ''),
      patientName: _string(data['patientName'], 'Patient'),
      doctorName: _string(data['doctorName'], 'Doctor'),
      lastMessage: _string(data['lastMessage'], ''),
      lastMessageTime:
          DateTime.tryParse(_string(data['lastMessageTime'], '')),
      lastSenderId: _string(data['lastSenderId'], ''),
      patientUnread: (data['patientUnread'] as int?) ?? 0,
      doctorUnread: (data['doctorUnread'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'doctorId': doctorId,
    'patientName': patientName,
    'doctorName': doctorName,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String() ?? '',
    'lastSenderId': lastSenderId,
    'participants': [patientId, doctorId],
    'patientUnread': patientUnread,
    'doctorUnread': doctorUnread,
    'createdAt': DateTime.now().toIso8601String(),
  };
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.type,
    required this.createdAt,
    this.voiceUrl = '',
    this.duration = 0,
    this.isRead = false,
  });

  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String type; // 'text' | 'voice'
  final String voiceUrl;
  final int duration; // seconds
  final DateTime createdAt;
  final bool isRead;

  bool get isVoice => type == 'voice';

  factory ChatMessage.fromMap(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: _string(data['senderId'], ''),
      senderName: _string(data['senderName'], ''),
      text: _string(data['text'], ''),
      type: _string(data['type'], 'text'),
      voiceUrl: _string(data['voiceUrl'], ''),
      duration: (data['duration'] as int?) ?? 0,
      createdAt: DateTime.tryParse(_string(data['createdAt'], '')) ??
          DateTime.now(),
      isRead: data['isRead'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'type': type,
    'voiceUrl': voiceUrl,
    'duration': duration,
    'createdAt': DateTime.now().toIso8601String(),
    'isRead': isRead,
  };
}

IconData iconForRecordType(String type) {
  final normalized = type.toLowerCase();
  if (normalized.contains('lab')) return Icons.science_outlined;
  if (normalized.contains('prescription')) return Icons.medication_outlined;
  return Icons.description_outlined;
}

String _string(Object? value, String fallback) {
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

double _double(Object? value, double fallback) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

int _int(Object? value, int fallback) {
  if (value is int) return value;
  return int.tryParse('$value') ?? fallback;
}

String _initialsFromName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'NH';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
