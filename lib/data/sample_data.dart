import 'package:flutter/material.dart';

import 'models.dart';

const doctors = [
  Doctor(
    id: 'dr-carine-njoya',
    name: 'Dr. Carine Njoya',
    initials: 'CN',
    specialty: 'General Practitioner',
    clinic: 'Bamenda Medical Centre',
    distance: '1.2 km',
    rating: 4.9,
    nextAvailable: 'Today, 10:30 AM',
    experience: '8 years',
    languages: 'English, French',
    about:
        'Dr. Njoya provides attentive primary care for adults and families, with a focus on practical prevention and long-term wellbeing.',
  ),
  Doctor(
    id: 'dr-leslie-fomba',
    name: 'Dr. Leslie Fomba',
    initials: 'LF',
    specialty: 'Paediatrics',
    clinic: 'Azire Health Clinic',
    distance: '2.4 km',
    rating: 4.8,
    nextAvailable: 'Today, 3:15 PM',
    experience: '6 years',
    languages: 'English, Pidgin',
    about:
        'Dr. Fomba offers calm, family-centred healthcare for infants, children, and adolescents.',
  ),
  Doctor(
    id: 'dr-marie-tita',
    name: 'Dr. Marie Tita',
    initials: 'MT',
    specialty: 'Cardiology',
    clinic: 'Regional Hospital Bamenda',
    distance: '3.1 km',
    rating: 4.7,
    nextAvailable: 'Fri, 2:00 PM',
    experience: '11 years',
    languages: 'English, French',
    about:
        'Dr. Tita specialises in cardiovascular assessment, hypertension care, and ongoing cardiac health management.',
  ),
  Doctor(
    id: 'dr-alain-mbah',
    name: 'Dr. Alain Mbah',
    initials: 'AM',
    specialty: 'Dental Care',
    clinic: 'Mankon Dental Clinic',
    distance: '4.0 km',
    rating: 4.9,
    nextAvailable: 'Mon, 9:00 AM',
    experience: '9 years',
    languages: 'English, French',
    about:
        'Dr. Mbah provides preventive, restorative, and routine dental services in a comfortable clinical setting.',
  ),
];

const medications = [
  Medication(
    id: 'amoxicillin',
    name: 'Amoxicillin',
    dosage: '500 mg - 1 capsule',
    schedule: 'After lunch - 1:00 PM',
    duration: '4 days remaining',
    color: Color(0xFFFFE7D3),
  ),
  Medication(
    id: 'vitamin-c',
    name: 'Vitamin C',
    dosage: '1000 mg - 1 tablet',
    schedule: 'After breakfast - 8:00 AM',
    duration: '12 days remaining',
    color: Color(0xFFE2F1EE),
  ),
];

const medicalRecords = [
  MedicalRecord(
    id: 'full-blood-count',
    type: 'Laboratory results',
    title: 'Full blood count',
    date: '28 May 2026',
    icon: Icons.science_outlined,
    summary: 'Results are within the expected reference ranges.',
    provider: 'Bamenda Medical Centre',
  ),
  MedicalRecord(
    id: 'routine-consultation',
    type: 'Consultation note',
    title: 'Routine consultation',
    date: '18 May 2026',
    icon: Icons.description_outlined,
    summary: 'Follow-up review completed. Continue prescribed medication.',
    provider: 'Dr. Carine Njoya',
  ),
  MedicalRecord(
    id: 'amoxicillin-prescription',
    type: 'Prescription',
    title: 'Amoxicillin 500 mg',
    date: '18 May 2026',
    icon: Icons.medication_outlined,
    summary: 'Take one capsule after meals as prescribed.',
    provider: 'Dr. Carine Njoya',
  ),
  MedicalRecord(
    id: 'malaria-test',
    type: 'Laboratory results',
    title: 'Malaria parasite test',
    date: '04 Apr 2026',
    icon: Icons.science_outlined,
    summary: 'No malaria parasites were detected.',
    provider: 'Regional Hospital Bamenda',
  ),
];

final appointments = [
  Appointment(
    id: 'appointment-today',
    doctor: doctors[0],
    date: 'Today',
    time: '10:30 AM',
    type: 'Video consultation',
    status: 'upcoming',
  ),
  Appointment(
    id: 'appointment-friday',
    doctor: doctors[2],
    date: 'Fri, 05 Jun',
    time: '2:00 PM',
    type: 'Clinic visit',
    status: 'upcoming',
  ),
  Appointment(
    id: 'appointment-past',
    doctor: doctors[1],
    date: '18 May 2026',
    time: '9:15 AM',
    type: 'Clinic visit',
    status: 'past',
  ),
];

const demoProfile = PatientProfile(
  id: 'demo-patient',
  fullName: 'Flavien Ndikum',
  email: 'flavien@example.com',
  phoneNumber: '+237 6 70 00 00 00',
  patientCode: 'NKH-20481',
);

const notifications = [
  HealthNotification(
    id: 'appointment-today',
    category: 'appointment',
    title: 'Appointment today',
    message: 'Your video consultation with Dr. Carine Njoya is at 10:30 AM.',
    time: '8:10 AM',
    isRead: false,
  ),
  HealthNotification(
    id: 'medication-reminder',
    category: 'medication',
    title: 'Medication reminder',
    message: 'Take one capsule of Amoxicillin after lunch.',
    time: 'Yesterday',
    isRead: false,
  ),
  HealthNotification(
    id: 'record-added',
    category: 'record',
    title: 'Record added',
    message: 'Your full blood count results are now available.',
    time: '28 May',
    isRead: true,
  ),
];
