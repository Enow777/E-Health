# CHAPTER THREE

# MATERIALS AND METHODS

## 3.1 Introduction

This chapter presents the materials and methods used in the design and development of the Health Services mobile application. The application was conceived as a patient-centred platform for improving access to healthcare services in Cameroon. It brings together functions that are often handled separately or manually: doctor discovery, appointment booking, telemedicine, medical record management, and prescription tracking.

The chapter explains the development tools, the research design, the software development methodology, the system requirements, the proposed architecture, the data model, the implementation approach, and the testing procedures. It also discusses the security and ethical considerations that guided the design. The purpose is to show clearly how the problem identified in Chapter One was translated into a practical mobile solution.

The project follows an incremental development approach. At the present stage, the Flutter-based patient application has been developed as a functional prototype with the main screens, navigation flows, service pages, and widget tests. The cloud backend, real-time geolocation, and live video consultation services are defined within the system architecture and are intended for integration during the next implementation phase. This distinction is important because it presents the current state of the system accurately while providing a clear path towards the complete application.

## 3.2 Materials

The materials used for this project were selected based on four considerations: accessibility, suitability for mobile development, maintainability, and the need to support future expansion. Since the application is intended primarily for Android smartphone users, the development environment was organised around Flutter and the Android toolchain.

### 3.2.1 Software Materials

| Software material | Version or type | Purpose in the project |
| --- | --- | --- |
| Flutter | 3.35.3 | Development of the mobile user interface and application logic from a single codebase |
| Dart | 3.9.2 | Programming language used for the Flutter application |
| Android Studio / Android SDK | Android development toolchain | Android emulator support, device deployment, and application build tools |
| Visual Studio Code | Source-code editor | Editing, navigation, and debugging of the application code |
| Git | Version-control system | Tracking source-code changes during iterative development |
| Firebase | Backend-as-a-Service platform | Proposed backend for authentication, cloud data storage, and synchronisation |
| Cloud Firestore | NoSQL cloud database | Proposed persistent storage for user, doctor, appointment, record, and prescription data |
| Firebase Storage | Cloud object storage | Proposed storage for uploaded medical documents and diagnostic results |
| Firebase Cloud Messaging | Push-notification service | Proposed delivery of appointment and medication reminders |
| Video communication API | Secure real-time communication service | Proposed support for video and audio telemedicine consultations |
| Flutter Test | Flutter testing framework | Widget testing and functional verification of the mobile prototype |

Flutter was selected because it supports the development of responsive mobile interfaces using a single codebase. This reduces development time and makes it possible to maintain a consistent user experience across devices. Dart was used because it is the language supported directly by the Flutter framework. Firebase was selected as the proposed backend because it provides services that are useful for a mobile health platform, including authentication, cloud storage, real-time updates, and notification support.

### 3.2.2 Hardware Materials

The hardware requirements for development and testing are modest, which is consistent with the aim of producing a solution that can be developed and deployed without specialised infrastructure.

| Hardware material | Minimum specification | Purpose |
| --- | --- | --- |
| Development computer | Multi-core processor, 8 GB RAM, and at least 10 GB free storage | Source-code development, application build, and testing |
| Android smartphone or emulator | Android-compatible device with internet connectivity | Functional testing of the patient application |
| Internet connection | Mobile data or Wi-Fi | Dependency access during development and future use of cloud services |
| Camera and microphone | Standard smartphone hardware | Required for the proposed telemedicine consultation feature |
| GPS-enabled smartphone | Standard Android location capability | Required for the proposed nearby-doctor discovery feature |

The application is designed to run on ordinary Android smartphones. This is important because the target users should not need specialised equipment to access basic healthcare services.

## 3.3 Methodology

### 3.3.1 Research Design

This study adopts the design science research approach. Design science is appropriate because the study does not only describe a healthcare access problem; it develops a software artefact intended to address that problem. The artefact in this case is the Health Services mobile application.

The research began with the identification of common difficulties faced by patients when seeking healthcare services. These include the challenge of locating suitable doctors, long waiting times caused by manual appointment procedures, limited access to remote consultations, fragmented medical records, and poor prescription tracking. These problems were examined further through the literature review presented in Chapter Two.

The findings from the literature review informed the design of an integrated patient application. Instead of creating separate tools for individual tasks, the proposed system organises the patient journey within one mobile platform. A patient should be able to find a doctor, inspect the doctor's profile, select an appointment time, attend a remote consultation where appropriate, review medical records, and manage medication reminders without moving between unrelated applications.

The design science process used in this project followed the stages below:

1. Identification of the healthcare access problem.
2. Review of existing digital health solutions and relevant technologies.
3. Definition of the functional and non-functional requirements.
4. Design of the user flows, system architecture, and data structure.
5. Incremental implementation of the mobile application prototype.
6. Functional verification through static analysis and widget testing.
7. Identification of the remaining backend integration tasks and limitations.

### 3.3.2 Requirements Analysis

Requirements analysis was carried out to translate the healthcare challenges identified in Chapter One into clear system functions. The requirements were grouped into functional and non-functional requirements.

#### 3.3.2.1 Functional Requirements

Functional requirements describe the tasks that the application should allow users to perform.

| Code | Functional requirement |
| --- | --- |
| FR1 | The system shall allow a patient to create an account and sign in securely. |
| FR2 | The system shall allow a patient to search for doctors by name, speciality, clinic, proximity, and availability. |
| FR3 | The system shall display doctor profiles containing professional information, clinic details, rating, distance, and available consultation times. |
| FR4 | The system shall allow a patient to book a clinic visit or a video consultation. |
| FR5 | The system shall allow a patient to view upcoming and previous appointments. |
| FR6 | The system shall support appointment rescheduling and cancellation. |
| FR7 | The system shall provide secure access to medical records such as consultation notes, prescriptions, and laboratory results. |
| FR8 | The system shall allow patients to share selected medical records with authorised healthcare providers. |
| FR9 | The system shall allow patients to view active prescriptions and medication schedules. |
| FR10 | The system shall provide appointment and medication reminders. |
| FR11 | The system shall provide a secure entry point for video and audio telemedicine consultations. |
| FR12 | The system shall allow a patient to manage personal information, privacy settings, language, and support options. |

#### 3.3.2.2 Non-Functional Requirements

Non-functional requirements define the expected quality of the system.

| Requirement | Description |
| --- | --- |
| Usability | The application should have a simple interface that can be understood by users with varying levels of smartphone experience. |
| Accessibility | The main patient services should be reachable with few navigation steps and readable on common Android screen sizes. |
| Security | Sensitive health information should be protected through authentication, access control, secure transmission, and protected cloud storage. |
| Performance | Main screens should load promptly and interactions should remain responsive on ordinary smartphones. |
| Reliability | Appointment, record, and medication information should remain consistent when synchronised with the backend. |
| Maintainability | The source code should be organised by feature to support future updates and testing. |
| Scalability | The backend design should support an increasing number of users, doctors, records, and appointments. |
| Low-bandwidth awareness | The interface should avoid unnecessary network activity and use locally bundled visual assets where appropriate. |

### 3.3.3 Agile Software Development Life Cycle

The Agile Software Development Life Cycle was used for the implementation of the application. Agile was selected because the project contains several connected modules and requires regular review as the interface grows. A rigid development process would make it difficult to refine the user experience after observing how the screens work together.

Development was carried out incrementally. Each iteration focused on a manageable group of features, followed by code review, formatting, static analysis, and widget testing. This approach helped to identify navigation gaps early. For example, the first dashboard prototype introduced service entries for finding a doctor, booking a visit, viewing records, and managing medication. A subsequent iteration completed the destination pages and connected each service entry to its appropriate flow.

The main development iterations are summarised below.

| Iteration | Main activities | Result |
| --- | --- | --- |
| Iteration 1 | Review of the project proposal and existing chapters; identification of the patient journey | Initial information architecture and visual direction |
| Iteration 2 | Development of dashboard, bottom navigation, doctor discovery, appointment list, records list, and profile | Navigable Flutter prototype |
| Iteration 3 | Refactoring into feature-based files; addition of doctor details, booking steps, medication tracking, record details, notifications, and settings | Maintainable application structure with complete patient flows |
| Iteration 4 | Addition of branded splash screen, onboarding screens, and locally bundled healthcare photographs | Refined first-launch experience |
| Iteration 5 | Connection of all dashboard service cards to real pages and addition of navigation tests | Complete service-card navigation and improved verification |
| Next iteration | Firebase authentication, Firestore persistence, geolocation, push notifications, and live consultation integration | Cloud-connected application |

The Agile process was particularly useful because it kept the implementation aligned with the usability objective of the project. Each iteration produced a working increment rather than a collection of disconnected screens.

### 3.3.4 System Design

System design describes the organisation of the application, the interactions between users and services, and the flow of data through the proposed platform.

#### 3.3.4.1 Use-Case Design

The system has three primary actors: the patient, the doctor, and the administrator. The patient is the main actor in the current mobile prototype. Doctors and administrators are included in the broader system design because they are required for the complete healthcare platform.

The patient can register, search for doctors, view doctor profiles, book appointments, attend remote consultations, access medical records, monitor prescriptions, and receive reminders. The doctor can maintain a professional profile, manage availability, review authorised patient information, conduct consultations, and issue prescriptions. The administrator can verify healthcare providers, manage user access, and monitor the platform.

![Figure 3.1: Use-case diagram for the Health Services application](documentation/figures/figure-3-1-use-case.png)

#### 3.3.4.2 Patient Activity Flow

The patient activity flow begins when the user launches the application. A first-time user sees the splash screen and onboarding pages before entering the main application. From the home screen, the user may search for a doctor directly or open the booking service. After choosing a suitable doctor, the user selects a consultation date, time, and consultation type. The application presents a confirmation before the appointment is stored. For returning users, the home screen also provides direct access to medication reminders, records, notifications, and upcoming consultations.

![Figure 3.2: Patient appointment-booking activity diagram](documentation/figures/figure-3-2-activity.png)

#### 3.3.4.3 Proposed System Architecture

The proposed platform follows a client-server architecture. The Flutter mobile application acts as the client. Firebase services provide the proposed backend layer for authentication, persistent data storage, document storage, and notifications. External services support location and telemedicine where required.

The architecture is organised into four layers:

1. **Presentation layer:** Flutter screens and reusable widgets that display information and collect user input.
2. **Application layer:** Feature modules that manage doctor discovery, booking, records, medication, notifications, and profile settings.
3. **Backend services layer:** Firebase Authentication, Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging.
4. **External integration layer:** Mapping and geolocation services for nearby-doctor discovery, and a secure video communication service for telemedicine.

![Figure 3.3: Proposed system architecture](documentation/figures/figure-3-3-architecture.png)

The current prototype implements the presentation layer and the application navigation flows. The backend and external integration layers remain part of the next development phase.

#### 3.3.4.4 Data Model

The data model was designed around the main objects required for continuity of care. Each patient has a profile and can create appointments with registered doctors. An appointment may produce consultation notes, prescriptions, and related medical records. Notifications are associated with the relevant user and may refer to an appointment or a medication schedule.

![Figure 3.4: Proposed entity relationship diagram](documentation/figures/figure-3-4-erd.png)

The main entities are described below.

| Entity | Purpose | Examples of key attributes |
| --- | --- | --- |
| Patient | Stores the patient's account and profile information | patientId, fullName, email, phoneNumber, dateOfBirth |
| Doctor | Stores professional and clinic information | doctorId, fullName, speciality, clinic, rating, location |
| Appointment | Stores clinic and remote consultation bookings | appointmentId, patientId, doctorId, dateTime, type, status |
| MedicalRecord | Stores patient-controlled health documents and notes | recordId, patientId, appointmentId, type, title, fileUrl, createdAt |
| Prescription | Stores medication instructions issued during care | prescriptionId, patientId, doctorId, medicationName, dosage, schedule |
| Notification | Stores reminders and service updates | notificationId, userId, category, message, createdAt, isRead |

#### 3.3.4.5 User Interface Design

The interface was designed with simplicity as a primary requirement. Healthcare applications may be used by patients with different levels of digital literacy, including people who do not use complex mobile applications regularly. For this reason, the prototype avoids dense menus and excessive visual elements.

The visual system uses a calm green colour palette, clear typography, soft card surfaces, and consistent spacing. The home screen exposes the most important actions directly: finding a doctor, booking a visit, opening medical records, and managing medication. A bottom navigation bar provides access to the main sections of the application. The onboarding flow uses a small number of carefully selected images and short explanations to introduce the application without delaying access to the services.

The application source code is organised by feature. This supports maintainability because each major service has its own directory and screen files. Shared design components and theme definitions are stored separately from feature-specific code.

### 3.3.5 System Implementation

#### 3.3.5.1 Mobile Application Structure

The mobile application was implemented using Flutter and Dart. The project began as a standard Flutter scaffold and was progressively reorganised into a feature-based structure. The final prototype contains separate modules for onboarding, home, doctor discovery, appointments, medication, records, notifications, profile settings, and the application shell.

| Module | Responsibility |
| --- | --- |
| Core theme | Defines reusable colours, typography, input styles, and component styling |
| Shared widgets | Provides reusable page frames, cards, avatars, search fields, and helper functions |
| Data models | Defines doctor, medication, and medical record structures |
| Onboarding | Displays the splash screen and the three-page first-launch introduction |
| Home | Presents the patient dashboard and the primary service entry points |
| Doctors | Supports doctor search, speciality filters, doctor cards, and doctor profiles |
| Appointments | Supports appointment lists, doctor selection, scheduling, and confirmation |
| Medication | Displays active medication, schedules, reminders, and adherence progress |
| Records | Displays medical records and individual record details |
| Notifications | Displays appointment, medication, and record updates |
| Profile | Displays personal settings, privacy, language, support, and application information |

#### 3.3.5.2 Implemented Prototype Features

The current Flutter prototype implements the following patient-facing features:

1. A branded splash screen and onboarding flow.
2. A patient dashboard with the most important health services.
3. A searchable doctor directory with speciality filtering.
4. Detailed doctor profiles with clinic, rating, experience, distance, language, and availability information.
5. A booking flow for choosing a doctor, date, time, and consultation type.
6. A booking-confirmation state.
7. An appointment page showing upcoming and previous consultations.
8. A medication page with dosage instructions, schedules, and adherence progress.
9. A medical-record library and record-detail pages.
10. A notification page for appointments, medication reminders, and new records.
11. Profile and settings pages for personal information, privacy, language, support, and application information.

At this stage, realistic sample data is used to demonstrate the workflow. This allows the interface and navigation to be reviewed before backend persistence is introduced. It also reduces the risk of combining user-interface problems with backend integration problems during early testing.

#### 3.3.5.3 Planned Backend Integration

The next implementation stage will replace sample data with persistent cloud data. Firebase Authentication will support account creation and sign-in. Cloud Firestore will store profile, doctor, appointment, prescription, and notification data. Firebase Storage will store uploaded health documents. Firebase Cloud Messaging will support reminder delivery.

Geolocation will be integrated to determine the patient's approximate location and rank doctors by distance. A map service will support visual location display where required. Telemedicine will be integrated through a secure video communication service. The selection of the final telemedicine provider will take into account security, call quality on limited bandwidth, cost, and Android support.

### 3.3.6 Security, Privacy, and Ethical Considerations

Healthcare information is sensitive and must be handled carefully. The application was designed around the principle that the patient should remain aware of and in control of access to personal medical information.

The complete system should apply the following safeguards:

1. Secure user authentication before private information is displayed.
2. Role-based access control to separate patient, doctor, and administrator permissions.
3. Secure transmission of data using encrypted network connections.
4. Protected cloud storage for medical records and uploaded documents.
5. Patient-controlled sharing of selected records with authorised healthcare providers.
6. Restricted collection of personal data to information required for healthcare delivery.
7. Clear indication that telemedicine is not a replacement for emergency care or physical examination where required.
8. An audit trail for sensitive actions such as record access and prescription updates.

The prototype uses sample data only and does not contain real patient medical information. Before deployment with real users, security testing and an appropriate privacy review will be required.

### 3.3.7 System Testing

Testing was carried out incrementally as the prototype developed. The purpose was to identify layout, navigation, and structural problems before backend integration. Flutter static analysis and widget tests were used.

Static analysis was performed using the following command:

`flutter --no-version-check analyze --no-pub`

The analysis completed successfully with no issues reported.

Widget testing was performed using:

`flutter --no-version-check test --no-pub`

The implemented widget test suite contains five passing tests.

| Test case | Expected result | Status |
| --- | --- | --- |
| Splash screen opens onboarding and skip enters the main app | User reaches the patient dashboard after skipping onboarding | Passed |
| Patient dashboard renders the main health services | Dashboard content and primary service section are visible | Passed |
| Doctor discovery filters doctors by speciality | Selecting Paediatrics displays the relevant doctor and removes unrelated entries | Passed |
| Doctor profile opens the booking flow | Selecting a doctor profile and booking action opens date and consultation-type selection | Passed |
| Home service card opens a real page | Selecting Book a visit opens the doctor-selection page | Passed |

The tests confirm that the prototype's most important navigation paths are operational. More tests will be required after backend integration, including authentication tests, Firestore access-rule tests, upload tests, reminder tests, and telemedicine call-quality tests under different network conditions.

### 3.3.8 Challenges Encountered

Several practical challenges were encountered during development.

The first challenge was balancing the number of healthcare functions with the need to keep the interface simple. Since the application covers several services, there was a risk of producing a crowded dashboard. This was addressed by exposing only four primary services on the home screen and moving detailed actions into their respective pages.

The second challenge was maintaining consistency as the prototype expanded. The initial implementation was contained in a single source file, which became difficult to maintain. The codebase was reorganised into feature-based files with a shared theme and reusable components. This made the structure clearer and reduced duplication.

The third challenge concerned the separation between prototype design and backend implementation. It was necessary to demonstrate a complete user journey without introducing poorly tested handling of sensitive health data. The current approach uses realistic sample data for interface validation while reserving live patient data for the secured backend phase.

The fourth challenge arose from the local Flutter toolchain environment during testing. Some Flutter commands required access to the SDK cache outside the project directory. After the appropriate environment access was provided, static analysis and widget tests completed successfully.

## 3.4 Conclusion

This chapter has presented the materials and methods used to design and develop the Health Services mobile application. The study adopted a design science approach because its main outcome is a practical software artefact intended to improve healthcare access. Agile development supported the incremental implementation and refinement of the Flutter prototype.

The system design covers doctor discovery, appointment booking, telemedicine, medical records, prescriptions, notifications, privacy settings, and future cloud services. The current implementation provides a functional patient-facing prototype with complete navigation flows and verified widget tests. The next stage is to integrate the secured backend services, geolocation, notifications, and live telemedicine functionality described in the architecture.
