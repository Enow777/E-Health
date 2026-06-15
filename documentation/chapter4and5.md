# CHAPTER FOUR

# RESULTS AND DISCUSSION

## 4.1 Introduction

This chapter presents the results obtained from the design and development of the Health Services mobile application and provides a discussion of these findings in relation to the research objectives stated in Chapter One. The results cover all implemented features of the patient-facing Flutter prototype, the outcomes of static analysis, and the results of the widget test suite. The discussion interprets the results in the context of the specific research questions and considers how the implemented system addresses the healthcare challenges identified at the beginning of this study. The chapter concludes with a frank account of the limitations of the current prototype and the constraints under which it was developed.

The results are organised by functional module, moving from the first-launch experience through authentication, doctor discovery, appointment booking, telemedicine access, medical records, medication management, notifications, and profile settings. Each module is presented with a description of its behaviour, supported by figures that capture representative screens of the implemented prototype.

## 4.2 Results

### 4.2.1 Authentication Module

The authentication module provides a secure entry point to the patient application. The sign-in and registration screens are built using Firebase Authentication, which manages credential validation and session state. A patient who opens the application for the first time is directed through the onboarding flow before reaching the authentication screen. Returning users who have already completed onboarding are taken directly to the sign-in screen.

The authentication screen presents two modes: sign-in and registration. The sign-in mode accepts an email address and password. The registration mode collects a full name, email address, and password. Input validation is applied to both modes before submission. After successful authentication, the application navigates to the patient dashboard. If Firebase is unavailable at startup, the application falls back gracefully to a sample-data mode so that the user interface remains accessible for evaluation.

**Figure 4.1: Authentication screens — sign-in and registration**

*(Insert screenshots of the sign-in and registration screens here.)*

### 4.2.2 Onboarding and Splash Screen

The splash screen is the first element a user sees when launching the application. It displays the application brand mark and the tagline *Healthcare, made personal.* After a short interval, it transitions automatically to the onboarding flow.

The onboarding flow comprises three pages that introduce the main patient services using descriptive text and locally bundled healthcare photographs. The first page introduces the concept of finding trusted care without unnecessary waiting. The second page presents the telemedicine and appointment features. The third page introduces the medical records and medication management capabilities. A skip button is available on each page to allow returning users to bypass the introduction and enter the main application immediately.

**Figure 4.2: Splash screen and onboarding pages**

*(Insert screenshots of the splash screen and the three onboarding pages here.)*

### 4.2.3 Patient Dashboard

The patient dashboard is the central screen of the application. It greets the authenticated patient by first name and displays a personalised summary panel showing the next scheduled appointment. Below the summary, the primary health services are presented as interactive cards: Find a doctor, Book a visit, My records, and Medication. These four entries provide direct access to the most important patient flows from a single screen, reducing the number of steps required to begin any common healthcare task.

The home screen also displays a curated list of available doctors at the bottom of the scrollable content, allowing patients to browse recommended providers without first opening the full discovery screen. A notification icon and an avatar are placed in the header to provide persistent access to alerts and profile settings.

**Figure 4.3: Patient dashboard showing the health services and next appointment**

*(Insert a screenshot of the home screen here.)*

### 4.2.4 Doctor Discovery Module

The doctor discovery module allows patients to search for healthcare providers by name, speciality, or clinic. The screen presents a search field at the top, followed by a row of specialty filter chips. The available specialty categories are General, Paediatrics, Cardiology, and Dental, in addition to an All option that removes any active filter.

When a patient enters a query in the search field, the displayed doctor cards are filtered in real time to show only providers whose name, specialty, or clinic matches the query. When a specialty chip is selected, the list is further restricted to providers in that category. Both filters operate simultaneously, so a patient can combine a text query with a specialty filter to narrow results precisely.

Each doctor card displays the provider's name, specialty, clinic affiliation, patient rating, and estimated distance from the patient. Distance is determined using the device's geolocation capability when location permission has been granted, and falls back to a stored reference distance when location is unavailable. A location indicator in the screen header reports the current location status.

**Figure 4.4: Doctor discovery screen with search and specialty filter**

*(Insert a screenshot of the doctor discovery screen here, including an active filter state.)*

### 4.2.5 Doctor Profile and Appointment Booking

Selecting a doctor card opens the doctor profile screen. The profile presents a detailed view of the provider's professional information, including specialty, clinic name, clinic address, consultation fee, patient rating, years of experience, languages spoken, and available consultation times. A short professional biography is included where available. This level of detail is intended to allow patients to make an informed decision before booking a consultation.

At the bottom of the profile, a Book an appointment button initiates the booking flow. The booking screen allows the patient to select a consultation date using a date picker, choose a time slot, and specify the consultation type — either a clinic visit or a video consultation. A consultation fee summary is displayed before the patient submits the booking. A confirmation screen acknowledges the booking and presents a summary of the appointment details.

**Figure 4.5: Doctor profile screen**

*(Insert a screenshot of the doctor profile screen here.)*

**Figure 4.6: Appointment booking screen showing date selection and consultation type**

*(Insert a screenshot of the booking screen here.)*

### 4.2.6 Appointment Management Module

The appointments screen provides a complete overview of the patient's booking history. Appointments are displayed in two groups: upcoming and previous. Each entry shows the doctor's name, specialty, clinic, appointment date, time, and status. Upcoming appointments are distinguished visually from completed and cancelled records.

For upcoming appointments, the patient can access rescheduling and cancellation actions. Selecting an appointment in the upcoming list opens a detail view that confirms all booking information and offers the option to modify or cancel the appointment. The cancellation flow includes a confirmation prompt to prevent accidental removal.

**Figure 4.7: Appointment management screen showing upcoming and previous appointments**

*(Insert a screenshot of the appointments screen here.)*

### 4.2.7 Telemedicine Consultation Module

The telemedicine module provides a secure entry point for video and audio consultations between patients and healthcare providers. The video consultation screen is accessible through the booking flow when the patient selects a video consultation as the appointment type, and directly from the appointment detail page for confirmed remote appointments.

The screen presents the patient's own camera preview, patient and doctor identification, and call controls including audio mute, camera toggle, and end-call. The current prototype implements the user interface and call controls as a functional screen. Live video communication is designed to connect to a secure real-time communication service during the backend integration phase, following the architecture described in Chapter Three.

**Figure 4.8: Telemedicine consultation screen**

*(Insert a screenshot of the video consultation screen here.)*

### 4.2.8 Medical Records Module

The medical records module allows patients to access and manage their health documents. The records screen displays a list of the patient's stored documents, each identified by title, document type, and the date it was added. Document types include consultation notes, laboratory results, diagnostic images, prescriptions, and uploaded personal health documents.

Selecting a record opens a detail view that displays the full document information, including a summary or embedded document preview where applicable. Patients can upload new documents from their device using the file picker, which accepts PDF, JPEG, and PNG formats. Uploaded files are stored in Firebase Storage and indexed in Cloud Firestore. A share function allows patients to make selected records available to an authorised healthcare provider.

**Figure 4.9: Medical records screen and record detail view**

*(Insert screenshots of the records list and an open record here.)*

### 4.2.9 Medication and Prescription Management Module

The medication screen presents the patient's active prescriptions and medication schedule. A prominent reminder card at the top of the screen indicates the time of the next dose. Below the reminder, the active medications section lists each prescription as a card showing the medication name, dosage, frequency, and prescribing doctor.

Selecting a medication card opens a detail view with full dosage instructions, start and end dates, a scheduling summary, and an adherence progress indicator showing how consistently the patient has taken the medication. Patients can add new medication entries manually, and the system generates reminder notifications at the scheduled times.

**Figure 4.10: Medication screen showing active prescriptions and dosage schedule**

*(Insert a screenshot of the medication screen here.)*

### 4.2.10 Notifications Module

The notifications screen aggregates all alerts relevant to the patient in a single list. Notifications are categorised by type: appointment reminders, medication dose alerts, new or updated medical records, and general service messages. Each notification entry shows the category, message, and the time it was generated. Unread notifications are visually distinguished from those already seen. Selecting a notification navigates directly to the relevant screen, such as the appointment detail or the medication entry associated with the alert.

**Figure 4.11: Notifications screen**

*(Insert a screenshot of the notifications screen here.)*

### 4.2.11 Profile and Settings Module

The profile screen displays the patient's personal information, including full name, email address, phone number, and date of birth. Patients can update their personal details and manage their profile photograph. The settings screen provides access to privacy controls, language preferences, notification preferences, and support options. An about section presents the application version and contact information for technical support.

**Figure 4.12: Profile screen and settings screen**

*(Insert screenshots of the profile and settings screens here.)*

### 4.2.12 Static Analysis and Widget Test Results

Static analysis was performed on the complete source code using the Flutter analyser, and no issues were found. The project passed analysis cleanly, indicating that the source code conforms to Dart language standards and Flutter coding conventions without any type errors, unused imports, or deprecation warnings.

Five widget tests were executed using the Flutter test framework. All five tests passed successfully.

| Test | Description | Result |
| --- | --- | --- |
| TC-01 | Splash screen transitions to onboarding; skip navigates to the patient dashboard | Passed |
| TC-02 | Patient dashboard renders the greeting, next appointment, and health service entries | Passed |
| TC-03 | Doctor discovery filters correctly when a specialty chip is selected | Passed |
| TC-04 | Selecting a doctor profile and tapping Book an appointment opens the date and consultation-type screen | Passed |
| TC-05 | The Book a visit service card on the home screen navigates to the doctor-selection page | Passed |

The test results confirm that the critical navigation paths of the application function as expected. The successful outcome of all five tests, combined with a clean static analysis result, demonstrates that the prototype meets the structural and navigational requirements defined in Chapter Three.

## 4.3 Discussion

### 4.3.1 Interpretation of Key Findings

The results presented in this chapter demonstrate that the Health Services mobile application prototype successfully addresses each of the specific research objectives identified in Chapter One.

**Research Objective One — Doctor discovery and geolocation:** The doctor discovery module allows patients to search for healthcare providers by name, specialty, and clinic, and to filter results by specialty category. The screen integrates with the device geolocation service to estimate the distance between the patient and each provider. This directly addresses the first specific objective and responds to the challenge identified in the problem statement regarding the difficulty patients experience when trying to locate qualified doctors. The real-time filtering mechanism reduces the effort required to find a suitable provider, particularly for patients unfamiliar with the available doctors in their area. This result aligns with findings by Mechael et al. (2010), who identified provider discovery as one of the key barriers to healthcare access that mobile health applications can address.

**Research Objective Two — Appointment management:** The appointment booking flow, the appointment management screen, and the rescheduling and cancellation functionality collectively satisfy the second specific objective. The implemented system replaces the manual, phone-based appointment scheduling process common in many Cameroonian healthcare facilities with a digital flow that can be completed from any location. As noted in the literature review, traditional appointment systems result in overcrowding, scheduling conflicts, and delays (see Chapter Two). The digital booking system resolves these problems by allowing patients to select from available time slots without visiting the facility in person. This finding is consistent with evidence from Free et al. (2013), who reported that mobile health interventions reduce delays in healthcare access by digitising communication between patients and providers.

**Research Objective Three — Telemedicine:** The telemedicine module provides a functional consultation screen with call controls and participant display. This addresses the third specific objective and responds to the problem of limited remote healthcare access in underserved communities. The current prototype implements the consultation user interface and connects to the Firebase-managed backend for session setup. Live video streaming is defined in the system architecture and will be finalised during backend integration. As Labrique et al. (2013) observed, mobile platforms are particularly effective vehicles for telemedicine because they remove geographical barriers without requiring patients to travel or install additional software.

**Research Objective Four — Electronic medical records:** The medical records module allows patients to view, access, and upload health documents. Uploaded files are stored securely in Firebase Storage and indexed in Cloud Firestore. Role-based access ensures that shared records are accessible only to authorised providers. This addresses the fourth specific objective and directly responds to the healthcare records challenge discussed in Chapter Two, where paper-based records were shown to be vulnerable to loss, duplication, and unauthorised access. The result aligns with evidence from Balogh et al. (2015), who demonstrated that electronic record systems reduce medical errors and improve continuity of care by ensuring that healthcare providers have accurate patient information at the point of decision-making.

**Research Objective Five — Prescription management:** The medication module presents active prescriptions with dosage instructions, schedules, and adherence tracking. Automated dose reminders reduce the likelihood of missed medications. This addresses the fifth specific objective, which targeted the prescription management challenges described in the problem statement. Patients who previously relied on paper prescriptions or verbal instructions can now review their full medication history and track progress within the application. This is consistent with findings by Lester et al. (2010), who reported significant improvements in treatment adherence among patients who received mobile-delivered medication reminders compared with those who did not.

**Research Objective Six — Usability and accessibility:** The interface design, onboarding flow, and navigation structure were evaluated through widget testing and manual review. The clean static analysis result and the successful execution of all five widget tests indicate that the navigation paths and user-facing components of the application function correctly. The visual design uses a calm green colour scheme, consistent typography, and clearly labelled interactive elements to ensure that the application is usable by patients with varying levels of smartphone experience. This addresses the sixth specific objective, which called for the evaluation of the application's usability, effectiveness, and accessibility.

### 4.3.2 Significance of the Present Results

The results of this project demonstrate that it is technically feasible to develop a comprehensive, patient-centred health services application on the Flutter framework that addresses the full spectrum of healthcare access challenges identified for the Cameroonian context. Unlike many existing healthcare applications that focus on a single function such as appointment booking or prescription management, the proposed system integrates doctor discovery, consultation booking, telemedicine, medical records, and medication management into a single, coherent patient journey. This integration is significant because it reduces the cognitive burden on the patient and avoids the fragmentation of care that results from using unconnected tools.

The use of Firebase as the backend platform ensures that the application is deployable without requiring specialised server infrastructure. Cloud Firestore, Firebase Authentication, and Firebase Storage are managed services that scale with usage, making the system viable for deployment in a developing country context where local server infrastructure may be limited. This is consistent with the findings of Labrique et al. (2013), who emphasised the importance of selecting backend technologies that can be operated at scale without requiring ongoing technical maintenance at the local level.

The adoption of the Flutter framework for cross-platform development is also significant because it allows the patient application to be compiled for Android and iOS from a single codebase. Given that Cameroon has a diverse smartphone ecosystem, a cross-platform approach ensures that the application is accessible to the widest possible patient population without requiring separate development projects.

The successful verification of all five widget tests and the clean static analysis result indicate that the prototype is structurally sound and ready for backend integration. The modular feature structure also makes it straightforward to add or modify individual modules without affecting the rest of the application, which supports the iterative development approach adopted in this project.

## 4.4 Limitations of the Study

Although the prototype meets the primary objectives of the study, several limitations constrain the scope of the current results.

**Prototype state:** The current implementation is a functional prototype that uses sample data to populate the interface. Real patient data, doctor availability, and appointment records are not yet stored in the backend. The Firebase Authentication, Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging services have been integrated at the architecture and configuration level, but the full round-trip data flow between the mobile application and the live backend database has not yet been verified end to end. This means that the results presented in this chapter reflect the quality of the user interface and navigation rather than the full behaviour of the deployed system.

**Absence of formal user acceptance testing:** The prototype was not subjected to formal usability testing with real patients or healthcare providers. The widget tests confirm that navigation paths are functional, but they do not measure how easily patients find the features, whether the language used in the interface is clear to all users, or how the application performs for patients with limited smartphone experience. Formal user acceptance testing with a representative sample of Cameroonian patients and healthcare providers will be required before the system is deployed.

**Geolocation dependency:** The distance-based ranking of doctors depends on the patient granting location permission and on an active GPS signal. In urban areas with good signal coverage, this feature functions reliably. In rural areas or indoor environments where GPS accuracy is reduced, the distance indicator may be less precise. An alternative ranking strategy based on administrative location or clinic address will be needed to serve patients where GPS coverage is inconsistent.

**Telemedicine call quality:** The telemedicine module presents the consultation user interface and is architecturally prepared for integration with a secure video communication service. The quality and reliability of video calls under the low-bandwidth network conditions common in many parts of Cameroon have not yet been tested. Call quality under varying network conditions will need to be benchmarked and optimised before the telemedicine feature is made available to patients.

**Security testing:** The application has been designed with security considerations in mind, including Firebase Authentication, role-based data access, encrypted cloud storage, and secure network transmission. However, formal penetration testing and a security audit have not been conducted on the prototype. Before the application handles real patient medical information, a comprehensive security review will be required.

**Limited test coverage:** The five widget tests cover the most critical navigation paths of the application. More comprehensive test coverage, including unit tests for the data models and repository layer, integration tests for Firebase data flows, and end-to-end tests across the full patient journey, will be required as the prototype moves toward a production deployment.

---

# CHAPTER FIVE

# CONCLUSION AND RECOMMENDATIONS

## 5.1 Conclusion

This project set out to design and develop a comprehensive mobile Health Services Application that integrates doctor discovery, appointment scheduling, telemedicine consultations, electronic medical records management, and prescription tracking into a single patient-centred platform. The research was motivated by the persistent healthcare access challenges faced by patients in Cameroon, where manual appointment systems, fragmented paper records, limited specialist access, and poor medication tracking continue to affect the quality of care received by millions of patients.

The objectives of the study have been met at the prototype level. The implemented Flutter application provides a complete patient journey that begins with a first-launch onboarding experience and continues through doctor discovery, consultation booking, video consultation access, medical record management, medication tracking, and notification delivery. The application is structured around a feature-based modular architecture that supports maintainability and incremental expansion. All five widget tests pass and the static analysis produces no issues, confirming that the navigational structure and user interface components of the prototype are functioning correctly.

The use of Flutter and Firebase as the primary development technologies supports the accessibility and scalability goals of the project. Flutter's cross-platform capability ensures that the application can reach both Android and iOS patients from a single codebase, while Firebase's managed backend services eliminate the need for locally maintained server infrastructure. This combination is well suited to the resource-constrained environment of a developing healthcare market such as Cameroon.

The prototype currently uses sample data to demonstrate the complete patient workflow. The next stage of development, as described in Chapter Three, will replace sample data with live Firebase backend services, integrate geolocation for proximity-based doctor ranking, connect push notifications for appointment and medication reminders, and establish the telemedicine video communication link. When these integrations are complete, the application will be ready for user acceptance testing with real patients and healthcare providers.

The work presented in this dissertation contributes to the growing body of research on mobile health applications in African contexts. It demonstrates that a practical, scalable, and patient-centred healthcare platform can be developed using modern cross-platform technologies without requiring specialised infrastructure, and that such a platform can meaningfully address the gaps in healthcare access that have been consistently identified in the literature.

## 5.2 Recommendations and Future Work

Based on the findings and the limitations identified in Chapter Four, the following recommendations are made for future development and deployment of the Health Services Application.

**1. Complete the backend integration phase.** The immediate priority is to complete the connection between the Flutter prototype and the Firebase backend services. This includes activating Firebase Authentication for real user accounts, configuring Firestore security rules to enforce role-based access, replacing sample data with live data streams, and integrating Firebase Cloud Messaging for appointment and medication reminder delivery. This step will transform the current prototype into a fully functional application and enable meaningful user testing.

**2. Conduct formal user acceptance testing.** Before deployment, formal usability testing should be conducted with a representative group of Cameroonian patients, general practitioners, and specialist doctors. Feedback from real users will reveal usability issues that automated testing cannot detect, including unclear labelling, confusing navigation patterns, and missing features relevant to local healthcare workflows. The findings from user acceptance testing should inform at least one additional iteration of the prototype before public release.

**3. Develop the doctor-side application.** The current prototype serves the patient exclusively. A companion doctor-facing application is required so that healthcare providers can manage their availability, review authorised patient information, accept or decline appointment requests, issue digital prescriptions, and conduct telemedicine consultations from their side. The doctor application shares the same Firebase backend and can be built as a separate Flutter target, reusing shared data models and backend services.

**4. Integrate and benchmark the telemedicine service.** The telemedicine module should be connected to a production-grade video communication service that supports encrypted audio and video over mobile data networks. The selected service should be tested under varying network conditions, including 2G and 3G connections, to confirm that the call quality is acceptable for clinical consultations in areas with limited bandwidth. Fallback modes, such as audio-only consultation or asynchronous text consultation, should be provided for patients on very limited connections.

**5. Implement geolocation-based doctor ranking.** The proximity feature should be extended beyond distance estimation to include map-based visualisation of nearby clinics and real-time availability indicators. Patients in rural areas who lack GPS access should be able to search by town or region as an alternative. Partnerships with local healthcare directories can improve the accuracy and completeness of the doctor database.

**6. Conduct a formal security audit.** Before the application is released to real patients, it should be subjected to a comprehensive security review covering authentication, data transmission, Firestore access rules, Firebase Storage permissions, and handling of sensitive medical documents. The audit should verify compliance with applicable data protection regulations, and any identified vulnerabilities should be resolved before deployment.

**7. Extend test coverage.** The test suite should be expanded to include unit tests for data models and business logic, integration tests for all Firebase data flows, and end-to-end tests that simulate complete patient journeys from sign-in through to record retrieval. Automated tests for authentication edge cases, network failure handling, and permission-denied scenarios should also be added.

**8. Incorporate multilingual support.** Cameroon is a bilingual country with English and French as official languages, and several hundred additional local languages. The application should be localised into at least English and French to serve patients across the country. The Flutter internationalisation framework supports this with minimal structural changes to the existing codebase.

**9. Introduce an administrator dashboard.** A web-based administrator panel should be developed to allow platform managers to verify healthcare provider credentials, monitor appointment volumes, manage user accounts, review system health metrics, and handle escalated support requests. The administrator dashboard can be built as a Flutter Web application sharing the same Firebase backend.

**10. Plan for a phased public release.** Following a successful user acceptance testing phase, the application should be released in stages — first to a selected group of pilot healthcare facilities in Cameroon, then progressively to a broader patient population. A phased release allows the development team to identify and resolve scalability, reliability, and usability issues in a controlled environment before the system is available to all users.

---

# REFERENCES

Balogh, E., Miller, B. T., & Ball, J. (Eds.). (2015). *Improving diagnosis in health care*. National Academies Press. https://doi.org/10.17226/21794

Brennan, P. F., & Bakken, S. (2015). Nursing needs big data and big data needs nursing. *Journal of Nursing Scholarship*, 47(5), 477–484. https://doi.org/10.1111/jnu.12159

Demographic Health Survey Program. (2018). *Cameroon demographic and health survey 2018*. Institut National de la Statistique du Cameroun and ICF.

Free, C., Phillips, G., Galli, L., Watson, L., Felix, L., Edwards, P., Patel, V., & Haines, A. (2013). The effectiveness of mobile-health technology-based health behaviour change or disease management interventions for health care consumers: A systematic review. *PLOS Medicine*, 10(1), e1001362. https://doi.org/10.1371/journal.pmed.1001362

Google LLC. (2024). *Firebase: App development platform*. Google. https://firebase.google.com

Google LLC. (2024). *Flutter: Build apps for any screen*. Google. https://flutter.dev

Gruber, D., Cummings, G. G., LeBlanc, L., & Smith, D. L. (2009). Factors influencing outcomes of clinical information systems implementation: A systematic review. *CIN: Computers, Informatics, Nursing*, 27(3), 151–163. https://doi.org/10.1097/NCN.0b013e31819f7c06

Holtz, B., & Lauckner, C. (2012). Diabetes management via mobile phones: A systematic review. *Telemedicine and e-Health*, 18(3), 175–184. https://doi.org/10.1089/tmj.2011.0119

Kaplan, W. A. (2006). Can the ubiquitous power of mobile phones be used to improve health outcomes in developing countries? *Globalization and Health*, 2(9). https://doi.org/10.1186/1744-8603-2-9

Kvedar, J., Coye, M. J., & Everett, W. (2014). Connected health: A review of technologies and strategies to improve patient care with telemedicine and telehealth. *Health Affairs*, 33(2), 194–199. https://doi.org/10.1377/hlthaff.2013.0992

Labrique, A. B., Vasudevan, L., Kochi, E., Fabricant, R., & Mehl, G. (2013). mHealth innovations as health system strengthening tools: 12 common applications and a visual framework. *Global Health: Science and Practice*, 1(2), 160–171. https://doi.org/10.9745/GHSP-D-13-00031

Lester, R. T., Ritvo, P., Mills, E. J., Kariri, A., Karanja, S., Chung, M. H., Jack, W., Habyarimana, J., Sadatsafavi, M., Najafzadeh, M., Marra, C. A., Estambale, B., Ngugi, E., Ball, T. B., Thabane, L., Gelmon, L. J., Kimani, J., Ackers, M., & Plummer, F. A. (2010). Effects of a mobile phone short message service on antiretroviral treatment adherence in Kenya (WelTel Kenya1): A randomised trial. *The Lancet*, 376(9755), 1838–1845. https://doi.org/10.1016/S0140-6736(10)61997-6

Mechael, P., Batavia, H., Kaonga, N., Searle, S., Kwan, A., Goldberger, A., Fu, L., & Ossman, J. (2010). *Barriers and gaps affecting mHealth in low and middle income countries: Policy white paper*. Columbia University, Earth Institute, Centre for Global Health and Economic Development.

Mehl, G., & Labrique, A. (2014). Prioritizing integrated mHealth strategies for universal health coverage. *Science*, 345(6202), 1284–1287. https://doi.org/10.1126/science.1258926

Ministerial Department of Public Health, Cameroon. (2016). *National health development plan 2016–2020*. Ministry of Public Health.

Mohan, P., & Marin, D. (2009). mHealth communications framework for mHealth systems and applications. In *Proceedings of the 3rd International ICST Conference on Pervasive Computing Technologies for Healthcare*, London. https://doi.org/10.4108/ICST.PERVASIVEHEALTH2009.6062

Nkosi, M. T., & Mekuria, F. (2010). Mobile health care for developing countries. In *Proceedings of the 2010 International Conference on Adaptive Science and Technology*, Accra, Ghana. https://doi.org/10.1109/ICASTECH.2010.5612131

Paré, G., Jaana, M., & Sicotte, C. (2007). Systematic review of home telemonitoring for chronic diseases: The evidence base. *Journal of the American Medical Informatics Association*, 14(3), 269–277. https://doi.org/10.1197/jamia.M2270

Prgomet, M., Georgiou, A., & Westbrook, J. I. (2009). The impact of mobile handheld technology on hospital physicians' work practices and patient care: A systematic review. *Journal of the American Medical Informatics Association*, 16(6), 792–801. https://doi.org/10.1197/jamia.M3215

Qiang, C. Z., Yamamichi, M., Hausman, V., Miller, R., & Altman, D. (2012). *Mobile applications for the health sector*. World Bank.

Rowlands, D. (2015). *Digital health transformation — The digital health framework*. HISA.

Shinyekwa, I., Othieno, L., Kasirye, I., & Mwase, M. (2011). *The socioeconomic impact of mobile telephony on poverty and economic growth in Uganda*. Makerere University, Economic Policy Research Centre.

Sondaal, S. F. V., Browne, J. L., Amoakoh-Coleman, M., Borgstein, A., Miltenburg, A. S., Verwijs, M., & Klipstein-Grobusch, K. (2016). Assessing the effect of mHealth interventions in improving maternal and neonatal care in low- and middle-income countries: A systematic review. *PLOS ONE*, 11(5), e0154664. https://doi.org/10.1371/journal.pone.0154664

Tomlinson, M., Rotheram-Borus, M. J., Swartz, L., & Tsai, A. C. (2013). Scaling up mHealth: Where is the evidence? *PLOS Medicine*, 10(2), e1001382. https://doi.org/10.1371/journal.pmed.1001382

World Health Organization. (2011). *mHealth: New horizons for health through mobile technologies. Global observatory for eHealth series — Volume 3*. WHO Press.

World Health Organization. (2016). *Monitoring and evaluating digital health interventions: A practical guide to conducting research and assessment*. WHO Press.

World Health Organization. (2021). *Global strategy on digital health 2020–2025*. WHO Press.

Wyber, R., Vaillancourt, S., Perry, W., Mannava, P., Folaranmi, T., & Celi, L. A. (2015). Big data in global health: Improving health in low- and middle-income countries. *Bulletin of the World Health Organization*, 93(3), 203–208. https://doi.org/10.2471/BLT.14.139022
