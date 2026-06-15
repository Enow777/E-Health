import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';

import 'models.dart';
import 'sample_data.dart' as sample;

const firestoreDatabaseName = 'ehealthdatabase';

class HealthRepository {
  HealthRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore =
          firestore ??
          FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: firestoreDatabaseName,
          ),
      _auth = auth ?? FirebaseAuth.instance,
      _storage = FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  String? get patientId => _auth.currentUser?.uid;
  String? get currentUid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _doctors =>
      _firestore.collection('doctors');
  CollectionReference<Map<String, dynamic>> get _patients =>
      _firestore.collection('patients');
  CollectionReference<Map<String, dynamic>> get _appointments =>
      _firestore.collection('appointments');
  CollectionReference<Map<String, dynamic>> get _records =>
      _firestore.collection('medicalRecords');
  CollectionReference<Map<String, dynamic>> get _prescriptions =>
      _firestore.collection('prescriptions');
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _recordShares =>
      _firestore.collection('recordShares');
  CollectionReference<Map<String, dynamic>> get _savedDoctors =>
      _firestore.collection('savedDoctors');
  CollectionReference<Map<String, dynamic>> get _userRoles =>
      _firestore.collection('userRoles');
  CollectionReference<Map<String, dynamic>> get _doctorProfiles =>
      _firestore.collection('doctorProfiles');
  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  // ── Streams ──────────────────────────────────────────────────────────────

  Stream<PatientProfile> watchProfile() {
    final uid = patientId;
    if (uid == null) return Stream.value(sample.demoProfile);
    return _patients.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        // Firestore doc not yet written — build from Firebase Auth data
        final user = _auth.currentUser;
        return PatientProfile(
          id: uid,
          fullName: (user?.displayName?.trim().isNotEmpty == true)
              ? user!.displayName!
              : 'Nkap Health Patient',
          email: user?.email ?? '',
          phoneNumber: '',
          patientCode: 'NKH-${uid.substring(0, 5).toUpperCase()}',
        );
      }
      return PatientProfile.fromMap(uid, snapshot.data() ?? {});
    });
  }

  /// Doctors are seeded on first launch so always fall back to sample doctors
  /// when the collection is empty (ensures the Discover screen is never blank).
  Stream<List<Doctor>> watchDoctors() {
    return _doctors.orderBy('fullName').snapshots().map((snapshot) {
      final values = snapshot.docs
          .map((doc) => Doctor.fromMap(doc.id, doc.data()))
          .toList();
      return values.isEmpty ? sample.doctors : values;
    });
  }

  /// Returns only real Firestore appointments for the signed-in patient.
  /// Returns an empty list (not sample data) when the patient has none yet.
  Stream<List<Appointment>> watchAppointments() {
    final uid = patientId;
    if (uid == null) return Stream.value(sample.appointments);
    return _appointments
        .where('patientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Returns only real Firestore medical records for the signed-in patient.
  Stream<List<MedicalRecord>> watchRecords() {
    final uid = patientId;
    if (uid == null) return Stream.value(sample.medicalRecords);
    return _records
        .where('patientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecord.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Returns only real Firestore prescriptions for the signed-in patient.
  Stream<List<Medication>> watchMedications() {
    final uid = patientId;
    if (uid == null) return Stream.value(sample.medications);
    return _prescriptions
        .where('patientId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Returns only real Firestore notifications for the signed-in patient.
  Stream<List<HealthNotification>> watchNotifications() {
    final uid = patientId;
    if (uid == null) return Stream.value(sample.notifications);
    return _notifications
        .where('patientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HealthNotification.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ── Appointments ──────────────────────────────────────────────────────────

  Future<void> createAppointment(Appointment appointment) async {
    final uid = patientId;
    if (uid == null) return;
    // Fetch patient name so the doctor's dashboard can display it
    final profileSnap = await _patients.doc(uid).get();
    final patientName = profileSnap.exists
        ? (profileSnap.data()?['fullName'] as String? ?? 'Patient')
        : 'Patient';
    final ref = _appointments.doc();
    final roomUrl = 'https://meet.jit.si/NkapHealth-${ref.id}';
    final data = {
      ...appointment.toMap(patientId: uid),
      'patientName': patientName,
      'roomUrl': roomUrl,
    };
    await ref.set(data);
    await _addNotification(
      uid: uid,
      category: 'appointment',
      title: 'Appointment confirmed',
      message:
          '${appointment.type} with ${appointment.doctor.name} on '
          '${appointment.date} at ${appointment.time}.',
    );
    // Notify the doctor too (if they are a registered user)
    await _addNotification(
      uid: appointment.doctor.id,
      category: 'appointment',
      title: 'New appointment request',
      message: '$patientName booked a ${appointment.type} on '
          '${appointment.date} at ${appointment.time}.',
    );
  }

  Future<void> setCallActive(String appointmentId, bool active) async {
    await _appointments.doc(appointmentId).set(
      {'callActive': active, if (!active) 'patientInCall': false},
      SetOptions(merge: true),
    );
  }

  Future<void> setPatientInCall(String appointmentId, bool inCall) async {
    await _appointments.doc(appointmentId).set(
      {'patientInCall': inCall},
      SetOptions(merge: true),
    );
  }

  Future<void> cancelAppointment(String appointmentId) async {
    await _appointments.doc(appointmentId).delete();
  }

  // ── Medications ───────────────────────────────────────────────────────────

  Future<void> createMedication(Medication medication) async {
    final uid = patientId;
    if (uid == null) return;
    await _prescriptions.add(medication.toMap(patientId: uid));
    await _addNotification(
      uid: uid,
      category: 'medication',
      title: 'Medication added',
      message: '${medication.name} has been added to your medication list.',
    );
  }

  Future<void> deleteMedication(String medicationId) async {
    await _prescriptions.doc(medicationId).delete();
  }

  Future<void> createMedicationReminder(Medication medication) async {
    final uid = patientId;
    if (uid == null) return;
    await _addNotification(
      uid: uid,
      category: 'medication',
      title: 'Medication reminder',
      message: 'Take ${medication.name}: ${medication.dosage}.',
      time: medication.schedule,
    );
  }

  // ── Medical Records ───────────────────────────────────────────────────────

  Future<void> uploadMedicalRecord({
    required String path,
    required String fileName,
    required String title,
    required String recordType,
    required String provider,
  }) async {
    final uid = patientId;
    if (uid == null) return;
    final ref = _storage.ref(
      'patients/$uid/medical-records/'
      '${DateTime.now().millisecondsSinceEpoch}-$fileName',
    );
    await ref.putFile(File(path));
    final url = await ref.getDownloadURL();
    await _records.add({
      'patientId': uid,
      'recordType': recordType,
      'title': title,
      'date': _todayLabel(),
      'summary': 'Uploaded document stored securely in Firebase Storage.',
      'provider': provider,
      'fileUrl': url,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _addNotification(
      uid: uid,
      category: 'record',
      title: 'Record uploaded',
      message: '$title is now available in your medical records.',
    );
  }

  Stream<List<RecordShare>> watchRecordShares() {
    final uid = patientId;
    if (uid == null) return Stream.value([]);
    return _recordShares
        .where('patientId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RecordShare.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> revokeRecordShare(String shareId) async {
    await _recordShares.doc(shareId).delete();
  }

  Future<void> shareMedicalRecord({
    required MedicalRecord record,
    required Doctor doctor,
  }) async {
    final uid = patientId;
    if (uid == null) return;
    await _recordShares.add({
      'patientId': uid,
      'recordId': record.id,
      'recordTitle': record.title,
      'doctorId': doctor.id,
      'doctorName': doctor.name,
      'access': 'read',
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _addNotification(
      uid: uid,
      category: 'record',
      title: 'Record shared',
      message: '${record.title} was shared with ${doctor.name}.',
    );
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  Future<void> markNotificationRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead() async {
    final uid = patientId;
    if (uid == null) return;
    final snapshot = await _notifications
        .where('patientId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();
    if (snapshot.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Patient profile ───────────────────────────────────────────────────────

  /// Called on registration — always writes the name the user just typed.
  Future<void> createPatientProfile({
    required String fullName,
    required String email,
  }) async {
    final uid = patientId;
    if (uid == null) return;
    await _patients.doc(uid).set(
      PatientProfile(
        id: uid,
        fullName: fullName.isNotEmpty ? fullName : 'Nkap Health Patient',
        email: email,
        phoneNumber: '',
        patientCode: 'NKH-${uid.substring(0, 5).toUpperCase()}',
      ).toMap(),
      SetOptions(merge: true),
    );
  }

  /// Called on sign-in — only creates the document if it does not yet exist.
  Future<void> ensurePatientProfile({
    required String fullName,
    required String email,
  }) async {
    final uid = patientId;
    if (uid == null) return;
    final doc = _patients.doc(uid);
    final snapshot = await doc.get();
    if (snapshot.exists) return;
    await doc.set(
      PatientProfile(
        id: uid,
        fullName: fullName.isNotEmpty ? fullName : 'Nkap Health Patient',
        email: email,
        phoneNumber: '',
        patientCode: 'NKH-${uid.substring(0, 5).toUpperCase()}',
      ).toMap(),
    );
  }

  Future<void> updatePatientProfile({
    required String fullName,
    required String phoneNumber,
    String? photoUrl,
  }) async {
    final uid = patientId;
    if (uid == null) return;
    await _patients.doc(uid).set(
      {
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
      },
      SetOptions(merge: true),
    );
  }

  Future<String> uploadPatientPhoto(File photo) async {
    final uid = patientId;
    if (uid == null) throw Exception('Not signed in');
    final ref = _storage.ref('patientPhotos/$uid/profile.jpg');
    await ref.putFile(photo);
    return ref.getDownloadURL();
  }

  Future<void> saveMessagingToken(String token) async {
    final uid = currentUid;
    if (uid == null) return;
    // Write to role-agnostic collection so Cloud Functions can reach both
    // patients and doctors with a single lookup.
    await _firestore.collection('userTokens').doc(uid).set({
      'token': token,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> savePatientLocation(Position position) async {
    final uid = patientId;
    if (uid == null) return;
    await _patients.doc(uid).set({
      'location': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      },
      'locationUpdatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  // ── Saved doctors ─────────────────────────────────────────────────────────

  Stream<bool> watchIsDoctorSaved(String doctorId) {
    final uid = patientId;
    if (uid == null) return Stream.value(false);
    return _savedDoctors
        .doc('${uid}_$doctorId')
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<List<Doctor>> watchSavedDoctors() {
    final uid = patientId;
    if (uid == null) return Stream.value([]);
    return _savedDoctors
        .where('patientId', isEqualTo: uid)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final doctorData = Map<String, dynamic>.from(
                data['doctorData'] as Map? ?? {},
              );
              return Doctor.fromMap(
                data['doctorId'] as String? ?? doc.id,
                doctorData,
              );
            }).toList());
  }

  Future<void> saveDoctor(Doctor doctor) async {
    final uid = patientId;
    if (uid == null) return;
    await _savedDoctors.doc('${uid}_${doctor.id}').set({
      'patientId': uid,
      'doctorId': doctor.id,
      'doctorData': doctor.toMap(),
      'savedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> unsaveDoctor(String doctorId) async {
    final uid = patientId;
    if (uid == null) return;
    await _savedDoctors.doc('${uid}_$doctorId').delete();
  }

  // ── Doctors ───────────────────────────────────────────────────────────────

  Future<void> seedDemoDoctors() async {
    final batch = _firestore.batch();
    for (final doctor in sample.doctors) {
      batch.set(_doctors.doc(doctor.id), doctor.toMap());
    }
    await batch.commit();
  }

  // ── Role management ───────────────────────────────────────────────────────

  Stream<String?> watchUserRole() {
    final uid = currentUid;
    if (uid == null) return Stream.value(null);
    return _userRoles.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    });
  }

  Future<void> setUserRole(String role) async {
    final uid = currentUid;
    if (uid == null) return;
    await _userRoles.doc(uid).set({
      'role': role,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // ── Doctor profile ────────────────────────────────────────────────────────

  Stream<DoctorProfile?> watchDoctorProfile() {
    final uid = currentUid;
    if (uid == null) return Stream.value(null);
    return _doctorProfiles.doc(uid).snapshots().map(
          (doc) =>
              doc.exists ? DoctorProfile.fromMap(uid, doc.data()!) : null,
        );
  }

  Future<void> createDoctorProfile({
    required String fullName,
    required String email,
  }) async {
    final uid = currentUid;
    if (uid == null) return;
    final profile = DoctorProfile(
      id: uid,
      fullName: fullName.isNotEmpty ? fullName : 'Doctor',
      email: email,
      specialties: [],
      clinic: '',
      phoneNumber: '',
      about: '',
      languages: 'English',
      experience: '',
    );
    // Write to both doctorProfiles (private) and doctors (public directory)
    await _doctorProfiles.doc(uid).set(profile.toMap());
    await _doctors.doc(uid).set(profile.toMap());
  }

  Future<void> addDoctorRating({
    required String doctorId,
    required String appointmentId,
    required double rating,
    String comment = '',
  }) async {
    final uid = patientId;
    if (uid == null) return;

    // Write rating document
    await _firestore
        .collection('ratings')
        .doc('${uid}_$appointmentId')
        .set({
      'doctorId': doctorId,
      'patientId': uid,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': DateTime.now().toIso8601String(),
    });

    // Mark the appointment as rated
    await _appointments
        .doc(appointmentId)
        .set({'isRated': true}, SetOptions(merge: true));

    // Recalculate doctor's average rating atomically
    await _firestore.runTransaction((tx) async {
      final doctorRef = _doctors.doc(doctorId);
      final snap = await tx.get(doctorRef);
      final data = snap.data() ?? {};
      final currentAvg = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (data['ratingCount'] as int?) ?? 0;
      final newCount = currentCount + 1;
      final newAvg =
          double.parse(((currentAvg * currentCount + rating) / newCount)
              .toStringAsFixed(1));
      final update = {'rating': newAvg, 'ratingCount': newCount};
      tx.update(doctorRef, update);
      // Mirror to doctorProfiles collection
      final profileRef = _doctorProfiles.doc(doctorId);
      final profileSnap = await tx.get(profileRef);
      if (profileSnap.exists) tx.update(profileRef, update);
    });

    // Notify the doctor
    await _addNotification(
      uid: doctorId,
      category: 'record',
      title: 'New patient rating',
      message: 'A patient left a ${rating.toStringAsFixed(0)}-star review.',
    );
  }

  Future<String> uploadDoctorPhoto(File photo) async {
    final uid = currentUid;
    if (uid == null) throw Exception('Not signed in');
    final ref = _storage.ref('doctorPhotos/$uid/profile.jpg');
    await ref.putFile(photo);
    return ref.getDownloadURL();
  }

  Future<void> updateDoctorSchedule({
    required Map<String, dynamic> weeklySchedule,
    required bool isAvailable,
  }) async {
    final uid = currentUid;
    if (uid == null) return;
    final update = {
      'weeklySchedule': weeklySchedule,
      'isAvailable': isAvailable,
    };
    await _doctorProfiles.doc(uid).set(update, SetOptions(merge: true));
    await _doctors.doc(uid).set(update, SetOptions(merge: true));
  }

  Future<void> updateDoctorProfile(DoctorProfile profile) async {
    final uid = currentUid;
    if (uid == null) return;
    await _doctorProfiles
        .doc(uid)
        .set(profile.toMap(), SetOptions(merge: true));
    await _doctors.doc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  // ── Doctor appointments ───────────────────────────────────────────────────

  Stream<List<Appointment>> watchDoctorAppointments() {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);
    return _appointments
        .where('doctorId', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Appointment.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    final snap = await _appointments.doc(appointmentId).get();
    await _appointments.doc(appointmentId).update({'status': status});
    if (!snap.exists) return;
    final data = snap.data()!;
    final patientId = data['patientId'] as String?;
    if (patientId == null) return;
    final doctorData = Map<String, dynamic>.from(
        data['doctor'] as Map? ?? {});
    final rawName = doctorData['fullName'] ?? doctorData['name'];
    final doctorName = (rawName is String && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : 'Your doctor';
    final date = data['date'] as String? ?? '';
    final time = data['time'] as String? ?? '';
    if (status == 'upcoming') {
      await _addNotification(
        uid: patientId,
        category: 'appointment',
        title: 'Appointment confirmed',
        message: 'Dr. $doctorName confirmed your appointment on $date at $time.',
      );
    } else if (status == 'cancelled') {
      await _addNotification(
        uid: patientId,
        category: 'appointment',
        title: 'Appointment declined',
        message:
            'Dr. $doctorName was unable to accept your appointment request for $date at $time.',
      );
    }
  }

  // ── Doctor patients ───────────────────────────────────────────────────────

  Stream<List<PatientProfile>> watchDoctorPatients() {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);
    return _appointments
        .where('doctorId', isEqualTo: uid)
        .snapshots()
        .asyncMap((snap) async {
          final ids = snap.docs
              .map((d) => d.data()['patientId'] as String?)
              .whereType<String>()
              .toSet()
              .toList();
          if (ids.isEmpty) return <PatientProfile>[];
          final docs = await Future.wait(ids.map((id) => _patients.doc(id).get()));
          return docs
              .where((d) => d.exists)
              .map((d) => PatientProfile.fromMap(d.id, d.data()!))
              .toList();
        });
  }

  Stream<List<MedicalRecord>> watchPatientRecords(String patientId) {
    return _records
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MedicalRecord.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<Medication>> watchPatientMedications(String patientId) {
    return _prescriptions
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Medication.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ── Doctor writes for patient ─────────────────────────────────────────────

  Future<void> addPatientRecord({
    required String patientId,
    required String title,
    required String recordType,
    required String summary,
    required String providerName,
  }) async {
    final uid = currentUid;
    if (uid == null) return;
    await _records.add({
      'patientId': patientId,
      'doctorId': uid,
      'recordType': recordType,
      'title': title,
      'date': _todayLabel(),
      'summary': summary,
      'provider': providerName,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _addNotification(
      uid: patientId,
      category: 'record',
      title: 'New record added',
      message: '$title has been added to your medical records.',
    );
  }

  Future<void> addPatientPrescription({
    required String patientId,
    required Medication medication,
    required String providerName,
  }) async {
    final uid = currentUid;
    if (uid == null) return;
    await _prescriptions.add({
      ...medication.toMap(patientId: patientId, doctorId: uid),
      'provider': providerName,
    });
    await _addNotification(
      uid: patientId,
      category: 'medication',
      title: 'New prescription',
      message: '${medication.name} has been prescribed for you.',
    );
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  static String buildChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<ChatConversation>> watchConversations() {
    final uid = currentUid;
    if (uid == null) return Stream.value([]);
    return _chats
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ChatConversation.fromMap(d.id, d.data()))
          .toList();
      list.sort((a, b) {
        final ta =
            a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final tb =
            b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return tb.compareTo(ta);
      });
      return list;
    });
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatMessage.fromMap(d.id, d.data()))
            .toList());
  }

  Future<ChatConversation> getOrCreateConversation({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
  }) async {
    final cid = buildChatId(patientId, doctorId);
    final doc = await _chats.doc(cid).get();
    if (!doc.exists) {
      final now = DateTime.now().toIso8601String();
      await _chats.doc(cid).set({
        'patientId': patientId,
        'doctorId': doctorId,
        'patientName': patientName,
        'doctorName': doctorName,
        'lastMessage': '',
        'lastMessageTime': now,
        'lastSenderId': '',
        'participants': [patientId, doctorId],
        'patientUnread': 0,
        'doctorUnread': 0,
        'createdAt': now,
      });
    }
    final snap = await _chats.doc(cid).get();
    return ChatConversation.fromMap(cid, snap.data() ?? {});
  }

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': 'text',
      'voiceUrl': '',
      'duration': 0,
      'createdAt': now,
      'isRead': false,
    });
    final snap = await _chats.doc(chatId).get();
    final data = snap.data() ?? {};
    final isPatient = data['patientId'] == senderId;
    await _chats.doc(chatId).set({
      'lastMessage': text,
      'lastMessageTime': now,
      'lastSenderId': senderId,
      if (isPatient)
        'doctorUnread': ((data['doctorUnread'] as int?) ?? 0) + 1
      else
        'patientUnread': ((data['patientUnread'] as int?) ?? 0) + 1,
    }, SetOptions(merge: true));
  }

  Future<void> sendVoiceMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String voiceUrl,
    required int duration,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': '',
      'type': 'voice',
      'voiceUrl': voiceUrl,
      'duration': duration,
      'createdAt': now,
      'isRead': false,
    });
    final snap = await _chats.doc(chatId).get();
    final data = snap.data() ?? {};
    final isPatient = data['patientId'] == senderId;
    await _chats.doc(chatId).set({
      'lastMessage': '🎤 Voice note',
      'lastMessageTime': now,
      'lastSenderId': senderId,
      if (isPatient)
        'doctorUnread': ((data['doctorUnread'] as int?) ?? 0) + 1
      else
        'patientUnread': ((data['patientUnread'] as int?) ?? 0) + 1,
    }, SetOptions(merge: true));
  }

  Future<String> uploadVoiceNote(String chatId, String filePath) async {
    final uid = currentUid ?? 'unknown';
    final ref = _storage.ref(
      'voice_notes/$chatId/${uid}_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await ref.putFile(File(filePath));
    return ref.getDownloadURL();
  }

  Future<void> markConversationRead(String chatId, String uid) async {
    final snap = await _chats.doc(chatId).get();
    if (!snap.exists) return;
    final isPatient = (snap.data() ?? {})['patientId'] == uid;
    await _chats.doc(chatId).set(
      {if (isPatient) 'patientUnread': 0 else 'doctorUnread': 0},
      SetOptions(merge: true),
    );
  }

  /// Marks all messages sent by the OTHER party as read so the sender sees
  /// blue double-ticks. Call this whenever the user opens the chat screen.
  Future<void> markMessagesRead(String chatId, String currentUid) async {
    final snap = await _chats
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    var count = 0;
    for (final doc in snap.docs) {
      if (doc.data()['senderId'] != currentUid) {
        batch.update(doc.reference, {'isRead': true});
        count++;
      }
    }
    if (count > 0) await batch.commit();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _addNotification({
    required String uid,
    required String category,
    required String title,
    required String message,
    String? time,
  }) async {
    await _notifications.add(
      HealthNotification(
        id: '',
        category: category,
        title: title,
        message: message,
        time: time ?? _nowLabel(),
        isRead: false,
      ).toMap(patientId: uid),
    );
  }
}

HealthRepository? tryHealthRepository() {
  if (Firebase.apps.isEmpty) return null;
  return HealthRepository();
}

String _todayLabel() {
  final now = DateTime.now();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
}

String _nowLabel() {
  final now = DateTime.now();
  final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
  final m = now.minute.toString().padLeft(2, '0');
  final ampm = now.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ampm';
}
