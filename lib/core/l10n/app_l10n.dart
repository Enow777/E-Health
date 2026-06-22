import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Access the current translations anywhere inside the widget tree:
///   final l10n = AppL10n.of(context);
class AppL10n {
  const AppL10n(this._lang);
  final String _lang;
  bool get _fr => _lang == 'fr';

  static AppL10n of(BuildContext context) =>
      Localizations.of<AppL10n>(context, AppL10n) ?? const AppL10n('en');

  static const delegate = _AppL10nDelegate();

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supportedLocales = [Locale('en'), Locale('fr')];

  // ── Navigation ────────────────────────────────────────────────────────────
  String get home => _fr ? 'Accueil' : 'Home';
  String get discover => _fr ? 'Découvrir' : 'Discover';
  String get bookings => _fr ? 'Agenda' : 'Bookings';
  String get messages => 'Messages';
  String get profile => _fr ? 'Profil' : 'Profile';
  String get dashboard => _fr ? 'Tableau' : 'Dashboard';
  String get schedule => _fr ? 'Agenda' : 'Schedule';
  String get patients => 'Patients';

  // ── Common actions ────────────────────────────────────────────────────────
  String get cancel => _fr ? 'Annuler' : 'Cancel';
  String get done => _fr ? 'Terminé' : 'Done';
  String get continueBtn => _fr ? 'Continuer' : 'Continue';
  String get skip => _fr ? 'Ignorer' : 'Skip';
  String get getStarted => _fr ? 'Commencer' : 'Get started';
  String get signOut => _fr ? 'Se déconnecter' : 'Sign out';
  String get signedOut => _fr ? 'Déconnecté' : 'Signed out';
  String get saveChanges => _fr ? 'Enregistrer les modifications' : 'Save changes';
  String get remove => _fr ? 'Supprimer' : 'Remove';
  String get filter => _fr ? 'Filtrer' : 'Filter';
  String get manage => _fr ? 'Gérer' : 'Manage';
  String get more => _fr ? 'Plus' : 'More';
  String get less => _fr ? 'Moins' : 'Less';
  String get select => _fr ? 'Sélectionner' : 'Select';
  String get seeAll => _fr ? 'Voir tout' : 'See all';
  String get from => _fr ? 'De' : 'From';
  String get to => _fr ? 'À' : 'To';

  // ── Common labels ─────────────────────────────────────────────────────────
  String get today => _fr ? "Aujourd'hui" : 'Today';
  String get pending => _fr ? 'En attente' : 'Pending';
  String get upcoming => _fr ? 'À venir' : 'Upcoming';
  String get completed => _fr ? 'Terminé' : 'Completed';
  String get cancelled => _fr ? 'Annulé' : 'Cancelled';
  String get email => 'E-mail';
  String get phone => _fr ? 'Téléphone' : 'Phone';
  String get about => _fr ? 'À propos' : 'About';
  String get languages => _fr ? 'Langues' : 'Languages';
  String get specialties => _fr ? 'Spécialités' : 'Specialties';
  String get language => _fr ? 'Langue' : 'Language';
  String get english => _fr ? 'Anglais' : 'English';
  String get french => 'Français';
  String get date => 'Date';
  String get patient => 'Patient';
  String get total => 'Total';
  String get records => _fr ? 'Dossiers' : 'Records';
  String get medications => _fr ? 'Médicaments' : 'Medication';
  String get version => _fr ? 'Version' : 'Version';
  String get notConnected => _fr ? 'Non connecté' : 'Not connected';
  String get allFilter => _fr ? 'Tous' : 'All';
  String get newLabel => _fr ? 'Nouveau' : 'New';
  String distanceAway(String d) => _fr ? d : '$d away';
  String get youPrefix => _fr ? 'Vous' : 'You';
  String get copyLinkHint => _fr ? 'Appuyez pour copier · partagez avec votre interlocuteur' : 'Tap the link to copy · share with your participant';

  // ── Greetings ─────────────────────────────────────────────────────────────
  String get goodMorning => _fr ? 'Bonjour' : 'Good morning';
  String get goodAfternoon => _fr ? 'Bon après-midi' : 'Good afternoon';
  String get goodEvening => _fr ? 'Bonsoir' : 'Good evening';
  String get howAreYou => _fr ? 'Comment vous sentez-vous ?' : 'How are you feeling today?';

  // ── Months & days (for date strips / labels) ──────────────────────────────
  List<String> get monthsFull => _fr
      ? ['Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc']
      : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  List<String> get dayNames => _fr
      ? ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM']
      : ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  List<String> get dayNamesLong => _fr
      ? ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
      : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  // ── Onboarding ─────────────────────────────────────────────────────────────
  String get splashTagline => _fr ? 'Des soins de santé\npersonnalisés.' : 'Healthcare,\nmade personal.';
  String get splashSub => _fr ? 'Un moyen plus simple de rester connecté aux soins dont vous avez besoin.' : 'A simpler way to stay connected to the care you need.';
  String get onb1Tag => _fr ? 'DES SOINS, PLUS PROCHES DE VOUS' : 'CARE, CLOSER TO YOU';
  String get onb1Title => _fr ? 'Trouvez des soins de confiance\nsans attendre.' : 'Find trusted care\nwithout the wait.';
  String get onb1Desc => _fr ? "Découvrez des médecins à proximité, consultez leurs spécialités et réservez une visite adaptée à votre emploi du temps." : 'Discover nearby doctors, review their specialties, and book a visit that fits your day.';
  String get onb2Tag => _fr ? 'CONSULTEZ DE PARTOUT' : 'CONSULT FROM ANYWHERE';
  String get onb2Title => _fr ? 'Parlez à votre médecin\noù que vous soyez.' : 'Speak to your doctor\nwherever you are.';
  String get onb2Desc => _fr ? 'Participez à des consultations vidéo sécurisées et restez connecté à des soins de qualité depuis chez vous.' : 'Attend secure video consultations and stay connected to quality care from home.';
  String get onb3Tag => _fr ? 'UN ESPACE POUR VOTRE SANTÉ' : 'ONE PLACE FOR YOUR HEALTH';
  String get onb3Title => _fr ? 'Votre historique de soins,\ntoujours à portée.' : 'Your care history,\nalways within reach.';
  String get onb3Desc => _fr ? 'Gardez vos rendez-vous, prescriptions et dossiers médicaux organisés dans un espace privé.' : 'Keep appointments, prescriptions, and medical records organized in one private space.';

  // ── Auth ───────────────────────────────────────────────────────────────────
  String get createPatientAccount => _fr ? 'Créer votre compte patient' : 'Create your patient account';
  String get welcomeBack => _fr ? 'Bon retour' : 'Welcome back';
  String get signInSubtitle => _fr ? 'Connectez-vous pour prendre rendez-vous et gérer vos dossiers.' : 'Sign in securely to book care, view records, and manage medication reminders.';
  String get fullName => _fr ? 'Nom complet' : 'Full name';
  String get emailAddress => _fr ? 'Adresse e-mail' : 'Email address';
  String get password => _fr ? 'Mot de passe' : 'Password';
  String get createAccount => _fr ? 'Créer un compte' : 'Create account';
  String get signIn => _fr ? 'Se connecter' : 'Sign in';
  String get alreadyHaveAccount => _fr ? "J'ai déjà un compte" : 'I already have an account';
  String get createNewAccount => _fr ? 'Créer un nouveau compte' : 'Create a new account';
  String get enterYourFullName => _fr ? 'Entrez votre nom complet' : 'Enter your full name';
  String get enterValidEmail => _fr ? 'Entrez un e-mail valide' : 'Enter a valid email';
  String get useAtLeast6Chars => _fr ? 'Au moins 6 caractères' : 'Use at least 6 characters';

  // ── Role selection ─────────────────────────────────────────────────────────
  String get howWillYouUse => _fr ? 'Comment allez-vous utiliser\nNkap Health ?' : 'How will you use\nNkap Health?';
  String get chooseYourRole => _fr ? 'Choisissez votre rôle pour personnaliser votre expérience.' : 'Choose your role to personalise your experience.';
  String get iAmPatient => _fr ? 'Je suis un Patient' : 'I am a Patient';
  String get patientRoleDesc => _fr ? 'Prenez rendez-vous, suivez vos médicaments et gérez vos dossiers médicaux.' : 'Book appointments, track medications, and manage your health records.';
  String get iAmDoctor => _fr ? 'Je suis un Médecin' : 'I am a Doctor';
  String get doctorRoleDesc => _fr ? 'Gérez les rendez-vous, consultez les dossiers patients et rédigez des prescriptions.' : 'Manage appointments, view patient records, and write prescriptions.';

  // ── Patient / Doctor setup ─────────────────────────────────────────────────
  String get yourProfile => _fr ? 'Votre profil' : 'Your profile';
  String get almostDone => _fr ? 'Presque terminé' : 'Almost done';
  String get setUpYourProfile => _fr ? 'Configurer votre profil' : 'Set up your profile';
  String get addAFewDetails => _fr ? 'Ajoutez quelques détails pour que les médecins puissent vous reconnaître.' : 'Add a few details so doctors can recognise you.';
  String get addProfilePhoto => _fr ? 'Ajouter une photo de profil (facultatif)' : 'Add profile photo (optional)';
  String get phoneNumber => _fr ? 'Numéro de téléphone' : 'Phone number';
  String get enterYourPhoneNumber => _fr ? 'Entrez votre numéro de téléphone' : 'Enter your phone number';
  String get photoUploadFailed => _fr ? 'Échec du téléversement :' : 'Photo upload failed:';
  String get tapToAddPhoto => _fr ? 'Appuyer pour ajouter une photo' : 'Tap to add profile photo';
  String get personalDetails => _fr ? 'Informations personnelles' : 'Personal details';
  String get tellPatientsAboutYourself => _fr ? 'Présentez-vous aux patients.' : 'Tell patients a bit about yourself.';
  String get age => _fr ? 'Âge' : 'Age';
  String get sex => _fr ? 'Sexe' : 'Sex';
  String get male => _fr ? 'Homme' : 'Male';
  String get female => _fr ? 'Femme' : 'Female';
  String get preferNotToSay => _fr ? 'Préférer ne pas dire' : 'Prefer not to say';
  String get nextProfessionalDetails => _fr ? 'Suivant' : 'Next — Professional details';
  String get professionalDetails => _fr ? 'Détails professionnels' : 'Professional details';
  String get helpPatientsFindRightDoctor => _fr ? 'Aidez les patients à trouver le bon médecin.' : 'Help patients find the right doctor.';
  String get hospitalClinic => _fr ? 'Hôpital / Clinique' : 'Hospital / Clinic';
  String get yearsOfExperience => _fr ? "Années d'expérience" : 'Years of experience';
  String get medicalSpecialties => _fr ? 'Spécialités médicales' : 'Medical specialties';
  String get select15Specialties => _fr ? 'Sélectionnez 1 à 5 domaines.' : 'Select 1 to 5 fields that describe your practice.';
  String get max5Specialties => _fr ? '5 spécialités maximum' : 'Maximum 5 specialties allowed';
  String get languagesSpoken => _fr ? 'Langues parlées' : 'Languages spoken';
  String get aboutBio => _fr ? 'À propos / Bio' : 'About / Bio';
  String get describeApproach => _fr ? 'Décrivez votre approche des soins…' : 'Describe your approach to patient care, areas of focus…';
  String get completeSetup => _fr ? 'Terminer la configuration' : 'Complete setup';
  String get selectAtLeastOneSpecialty => _fr ? 'Sélectionnez au moins une spécialité' : 'Select at least one specialty';
  String get enterHospitalName => _fr ? "Entrez le nom de l'hôpital" : 'Enter your hospital or clinic name';
  String get step1of2 => _fr ? 'Étape 1 sur 2' : 'Step 1 of 2';
  String get step2of2 => _fr ? 'Étape 2 sur 2' : 'Step 2 of 2';
  String stepOf2(int step) => _fr ? 'Étape $step sur 2' : 'Step $step of 2';
  String selectedOf5(int n) => _fr ? '$n/5 sélectionnées' : '$n/5 selected';

  // ── Home ───────────────────────────────────────────────────────────────────
  String get searchDoctors => _fr ? 'Chercher médecins, spécialités…' : 'Search doctors, specialties, clinics';
  String get nextAppointmentLabel => _fr ? 'PROCHAIN RENDEZ-VOUS' : 'NEXT APPOINTMENT';
  String get noUpcomingAppointments => _fr ? 'Aucun rendez-vous à venir' : 'No upcoming appointments';
  String get bookConsultationPrompt => _fr ? 'Prenez rendez-vous avec un médecin près de chez vous.' : 'Book a consultation with a doctor near you.';
  String get bookAVisit => _fr ? 'Prendre rendez-vous' : 'Book a visit';
  String get joinCall => _fr ? "Rejoindre" : 'Join call';
  String get yourHealthServices => _fr ? 'Vos services de santé' : 'Your health services';
  String get findADoctor => _fr ? 'Trouver un médecin' : 'Find a doctor';
  String get myRecords => _fr ? 'Mes dossiers' : 'My records';
  String get nearbyDoctors => _fr ? 'Médecins à proximité' : 'Nearby doctors';
  String get medicationReminder => _fr ? 'Rappel médicament' : 'Medication reminder';
  String get nextDose => _fr ? 'Prochaine dose :' : 'Next dose:';

  // ── Appointments (patient) ─────────────────────────────────────────────────
  String get appointmentsTitle => _fr ? 'Rendez-vous' : 'Appointments';
  String get pastConsultations => _fr ? 'Consultations passées' : 'Past consultations';
  String get noUpcomingApptMsg => _fr ? 'Aucun rendez-vous. Prenez rendez-vous pour commencer.' : 'No upcoming appointments. Book a visit to get started.';
  String get scheduledFor => _fr ? 'Prévu à' : 'Scheduled for';
  String get notYetTime => _fr ? "Pas encore l'heure" : 'Not yet time';
  String get doctorIsLive => _fr ? 'Médecin en direct !' : 'Doctor is live!';
  String get joinNow => _fr ? 'Rejoindre' : 'Join now';
  String get waitingForDoctor => _fr ? 'En attente du médecin…' : 'Waiting for doctor to start…';
  String get waitingForDoctorShort => _fr ? 'En attente…' : 'Waiting for doctor…';
  String get rateThisAppointment => _fr ? 'Évaluer ce rendez-vous' : 'Rate this appointment';
  String get youRatedThisAppointment => _fr ? 'Vous avez évalué ce rendez-vous' : 'You rated this appointment';
  String get appointmentWith => _fr ? 'Rendez-vous avec' : 'Appointment with';
  String get cancelAppointment => _fr ? 'Annuler le rendez-vous' : 'Cancel appointment';
  String get cannotCancelDemo => _fr ? "Impossible d'annuler ce rendez-vous de démonstration" : 'Cannot cancel this demo appointment';
  String get appointmentCancelled => _fr ? 'Rendez-vous annulé' : 'Appointment cancelled';
  String get rateYourAppointment => _fr ? 'Évaluer votre rendez-vous' : 'Rate your appointment';
  String get withDoctor => _fr ? 'Avec' : 'With';
  String get leaveComment => _fr ? 'Laisser un commentaire (facultatif)' : 'Leave a comment (optional)';
  String get submitRating => _fr ? "Soumettre l'évaluation" : 'Submit rating';
  String get ratingSubmitted => _fr ? 'Évaluation soumise — merci !' : 'Rating submitted — thank you!';
  String get failedToSubmit => _fr ? 'Échec :' : 'Failed to submit:';
  String get ratingPoor => _fr ? 'Médiocre' : 'Poor';
  String get ratingFair => _fr ? 'Passable' : 'Fair';
  String get ratingGood => _fr ? 'Bien' : 'Good';
  String get ratingVeryGood => _fr ? 'Très bien' : 'Very good';
  String get ratingExcellent => _fr ? 'Excellent' : 'Excellent';

  // ── Book appointment ───────────────────────────────────────────────────────
  String get bookAppointment => _fr ? 'Prendre rendez-vous' : 'Book appointment';
  String get chooseADate => _fr ? 'Choisir une date' : 'Choose a date';
  String get availableTimes => _fr ? 'Heures disponibles' : 'Available times';
  String get consultationType => _fr ? 'Type de consultation' : 'Consultation type';
  String get videoConsultation => _fr ? 'Consultation vidéo' : 'Video consultation';
  String get speakWithDoctorRemotely => _fr ? 'Parlez à votre médecin à distance' : 'Speak with your doctor remotely';
  String get clinicVisit => _fr ? 'Visite en clinique' : 'Clinic visit';
  String get urgencyLevel => _fr ? "Niveau d'urgence" : 'Urgency level';
  String get urgencyDesc => _fr ? "Informez le médecin de l'urgence de votre visite." : 'Let the doctor know how urgent your visit is.';
  String get sendRequest => _fr ? 'Envoyer la demande' : 'Send request';
  String get requestSent => _fr ? 'Demande envoyée !' : 'Request sent!';
  String get appointmentKeptForDemo => _fr ? 'Rendez-vous enregistré pour la démo' : 'Appointment kept for this demo session';
  String get urgencyNormal => _fr ? 'Normal' : 'Normal';
  String get urgencyNormalDesc => _fr ? 'Visite de routine — aucun problème immédiat.' : 'Routine visit — no immediate concern.';
  String get urgencyUrgent => _fr ? 'Urgent' : 'Urgent';
  String get urgencyUrgentDesc => _fr ? 'Nécessite une attention dans les prochains jours.' : 'Needs attention within the next day or two.';
  String get urgencyEmergency => _fr ? 'Urgence' : 'Emergency';
  String get urgencyEmergencyDesc => _fr ? 'Symptômes sévères — nécessite une attention immédiate.' : 'Severe symptoms — requires immediate attention.';
  String requestSentMsg(String date, String time, String doctorName) => _fr
      ? 'Votre demande pour le $date à $time a été envoyée à $doctorName. Vous serez notifié(e) dès qu\'elle sera confirmée.'
      : "Your request for $date at $time has been sent to $doctorName. You'll be notified once it's confirmed.";

  // ── Doctor schedule ────────────────────────────────────────────────────────
  String get pendingRequests => _fr ? 'Demandes en attente' : 'Pending requests';
  String get decline => _fr ? 'Refuser' : 'Decline';
  String get accept => _fr ? 'Accepter' : 'Accept';
  String get noConfirmedAppointments => _fr ? 'Aucun rendez-vous confirmé.' : 'No confirmed appointments yet.';
  String get noPastConsultations => _fr ? 'Aucune consultation passée.' : 'No past consultations.';
  String get markAsCompleted => _fr ? 'Marquer comme terminé' : 'Mark as completed';
  String get markedAsCompleted => _fr ? 'Marqué comme terminé' : 'Marked as completed';
  String get appointmentAccepted => _fr ? 'Rendez-vous accepté' : 'Appointment accepted';
  String get appointmentDeclined => _fr ? 'Rendez-vous refusé' : 'Appointment declined';
  String get endCall => _fr ? 'Terminer' : 'End call';
  String get openCall => _fr ? 'Ouvrir' : 'Open call';
  String get startCall => _fr ? 'Démarrer' : 'Start call';
  String get patientIsOnline => _fr ? 'Patient en ligne' : 'Patient is online';
  String get waitingForPatient => _fr ? 'En attente du patient…' : 'Waiting for patient…';
  String get callScheduledAt => _fr ? 'Appel prévu à' : 'Call scheduled at';
  String get pendingOverview => _fr ? 'En attente' : 'Pending';
  String get upcomingOverview => _fr ? 'À venir' : 'Upcoming';
  String get completedOverview => _fr ? 'Terminées' : 'Completed';

  // ── Video consultation ─────────────────────────────────────────────────────
  String get videoConsultationTitle => _fr ? 'Consultation vidéo' : 'Video consultation';
  String get tapJoinCall => _fr ? 'Appuyez sur "Rejoindre" pour entrer dans la salle sécurisée' : 'Tap "Join call" to enter the secure room';
  String get muteMic => _fr ? 'Couper le micro' : 'Mute mic';
  String get unmuteMic => _fr ? 'Activer le micro' : 'Unmute mic';
  String get turnOffCamera => _fr ? 'Éteindre la caméra' : 'Turn off camera';
  String get turnOnCamera => _fr ? 'Allumer la caméra' : 'Turn on camera';
  String get leave => _fr ? 'Quitter' : 'Leave';
  String get opening => _fr ? 'Ouverture…' : 'Opening…';
  String get howItWorks => _fr ? 'Comment ça marche' : 'How it works';
  String get callIsPrivate => _fr ? 'Votre appel est privé — seules les personnes avec ce lien peuvent rejoindre.' : 'Your call is private — only people with this link can join.';
  String get checkCameraAndMic => _fr ? 'Vérifiez la caméra et le micro avant de rejoindre.' : 'Check camera and microphone using the buttons above before joining.';
  String get joinCallOpensJitsi => _fr ? '"Rejoindre" ouvre une salle Jitsi Meet sécurisée dans votre navigateur.' : '"Join call" opens a secure Jitsi Meet room in your browser.';
  String get couldNotOpenCall => _fr ? "Impossible d'ouvrir l'appel. Copiez le lien et ouvrez-le manuellement." : 'Could not open the call. Please copy the link and open it manually.';
  String get roomLinkCopied => _fr ? 'Lien de la salle copié' : 'Room link copied to clipboard';

  // ── Notifications ──────────────────────────────────────────────────────────
  String get notificationsTitle => _fr ? 'Notifications' : 'Notifications';
  String get readAll => _fr ? 'Tout lire' : 'Read all';
  String get allNotificationsRead => _fr ? 'Toutes les notifications marquées comme lues' : 'All notifications marked as read';
  String get noNotificationsYet => _fr ? 'Pas encore de notifications' : 'No notifications yet';
  String get notificationsEmptyMsg => _fr ? "Les confirmations de rendez-vous et rappels apparaîtront ici." : 'Appointment confirmations, medication reminders, and record updates will appear here.';

  // ── Medical records ────────────────────────────────────────────────────────
  String get medicalRecords => _fr ? 'Dossiers médicaux' : 'Medical records';
  String get recordsSubtitle => _fr ? 'Votre historique de santé, organisé et privé.' : 'Your health history, organized and private.';
  String get recordsPrivacy => _fr ? 'Vous contrôlez qui peut consulter vos informations médicales.' : 'You control who can view your medical information.';
  String get uploadMedicalDocument => _fr ? 'Téléverser un document médical' : 'Upload medical document';
  String get recentRecords => _fr ? 'Dossiers récents' : 'Recent records';
  String get noRecordsYet => _fr ? "Aucun dossier pour l'instant" : 'No records yet';
  String get uploadFirstDocument => _fr ? 'Téléversez votre premier document avec le bouton ci-dessus.' : 'Upload your first medical document using the button above.';
  String get recordDetails => _fr ? 'Détails du dossier' : 'Record details';
  String get provider => _fr ? 'Prestataire' : 'Provider';
  String get access => _fr ? 'Accès' : 'Access';
  String get privateLabel => _fr ? 'Privé' : 'Private';
  String get summary => _fr ? 'Résumé' : 'Summary';
  String get viewDocument => _fr ? 'Voir le document' : 'View document';
  String get shareWithDoctor => _fr ? 'Partager avec un médecin' : 'Share with doctor';
  String get recordSharedWith => _fr ? 'Dossier partagé avec' : 'Record shared with';

  // ── Medications ────────────────────────────────────────────────────────────
  String get activeMedication => _fr ? 'Médicament actif' : 'Active medication';
  String get yourProgress => _fr ? 'Votre progression' : 'Your progress';
  String get medicationAdherence => _fr ? 'Observance médicamenteuse' : 'Medication adherence';
  String get keepTakingMeds => _fr ? 'Continuez à prendre vos médicaments selon le calendrier prévu.' : 'Keep taking your medications as scheduled to stay on track.';
  String get removeMedication => _fr ? 'Supprimer le médicament ?' : 'Remove medication?';
  String get asScheduled => _fr ? 'selon le calendrier' : 'as scheduled';
  String get noActiveMedications => _fr ? 'Aucun médicament actif' : 'No active medications';
  String get addMedsPrompt => _fr ? 'Ajoutez vos médicaments pour suivre les doses et recevoir des rappels.' : 'Add your medications to track doses and get reminders.';
  String get addMedication => _fr ? 'Ajouter un médicament' : 'Add medication';
  String get medicationName => _fr ? 'Nom du médicament' : 'Medication name';
  String get dosage => _fr ? 'Dosage (ex. 500mg)' : 'Dosage (e.g. 500mg)';
  String get medicationScheduleHint => _fr ? 'Calendrier (ex. Deux fois par jour)' : 'Schedule (e.g. Twice daily, 8 AM & 8 PM)';
  String get medicationDuration => _fr ? 'Durée (ex. 7 jours, En cours)' : 'Duration (e.g. 7 days, Ongoing)';
  String get saveMedication => _fr ? 'Enregistrer le médicament' : 'Save medication';
  String get medicationAdded => _fr ? 'Médicament ajouté' : 'Medication added';
  String get createReminder => _fr ? 'Créer un rappel' : 'Create reminder';
  String get reminderSavedFor => _fr ? 'Rappel enregistré pour' : 'Reminder saved for';
  String removeMedicationConfirm(String name) => _fr
      ? 'Supprimer $name de votre liste de médicaments ?'
      : 'Remove $name from your medication list?';

  // ── Profile (patient) ──────────────────────────────────────────────────────
  String get profileTitle => _fr ? 'Profil' : 'Profile';
  String get personalInformation => _fr ? 'Informations personnelles' : 'Personal information';
  String get privacyAndSecurity => _fr ? 'Confidentialité et sécurité' : 'Privacy and security';
  String get helpAndSupport => _fr ? 'Aide et assistance' : 'Help and support';
  String get aboutNkapHealth => _fr ? 'À propos de Nkap Health' : 'About Nkap Health';
  String get currentLanguage => _fr ? 'Langue actuelle' : 'Current language';

  // ── Settings ───────────────────────────────────────────────────────────────
  String get tapToChangePhoto => _fr ? 'Appuyer pour changer la photo' : 'Tap to change photo';
  String get patientId => _fr ? 'ID patient' : 'Patient ID';
  String get pleaseEnterYourFullName => _fr ? 'Veuillez entrer votre nom complet' : 'Please enter your full name';
  String get profileSaved => _fr ? 'Profil mis à jour' : 'Profile updated';
  String get appLock => _fr ? "Verrouillage de l'application" : 'App lock';
  String get usePasscode => _fr ? 'Utiliser un code ou la biométrie' : 'Use a passcode or biometrics';
  String get recordAccess => _fr ? 'Accès aux dossiers' : 'Record access';
  String get manageDoctorPermissions => _fr ? 'Gérer les autorisations des médecins' : 'Manage doctor permissions';
  String get changePassword => _fr ? 'Changer le mot de passe' : 'Change password';
  String get faq => _fr ? 'Foire aux questions' : 'Frequently asked questions';
  String get contactSupport => _fr ? 'Contacter le support' : 'Contact support';
  String get replyWithinOneDay => _fr ? 'Nous répondons généralement en un jour ouvrable' : 'We usually reply within one business day';
  String get emergencyGuidance => _fr ? "Guide d'urgence" : 'Emergency guidance';
  String get forUrgentCare => _fr ? "Pour les soins urgents, contactez les services d'urgence locaux" : 'For urgent care, contact local emergency services';
  String get privacyPolicy => _fr ? 'Politique de confidentialité' : 'Privacy policy';
  String get termsOfService => _fr ? "Conditions d'utilisation" : 'Terms of service';

  // ── App lock ───────────────────────────────────────────────────────────────
  String get enableAppLock => _fr ? 'Activer le verrouillage' : 'Enable app lock';
  String get appLockSubtitle => _fr ? 'Exiger un code PIN pour ouvrir l\'application' : 'Require a PIN to open the app';
  String get appLockNote => _fr ? 'Le code PIN est stocké localement sur cet appareil uniquement.' : 'The PIN is stored locally and applies to this device only.';
  String get changePin => _fr ? 'Changer le code PIN' : 'Change PIN';
  String get createPin => _fr ? 'Créer un code PIN à 4 chiffres' : 'Create a 4-digit PIN';
  String get enterPin => _fr ? 'Code PIN' : 'Enter PIN';
  String get confirmPinPrompt => _fr ? 'Confirmer le code PIN' : 'Confirm PIN';
  String get pinTooShort => _fr ? 'Le code PIN doit comporter 4 chiffres' : 'PIN must be 4 digits';
  String get pinMismatch => _fr ? 'Les codes PIN ne correspondent pas' : 'PINs do not match';
  String get pinSaved => _fr ? 'Verrouillage de l\'application activé' : 'App lock enabled';
  String get pinDisabled => _fr ? 'Verrouillage désactivé' : 'App lock disabled';

  // ── Record access ──────────────────────────────────────────────────────────
  String get noSharedRecords => _fr ? 'Aucun dossier partagé' : 'No shared records';
  String get noSharedRecordsMsg => _fr ? 'Les dossiers que vous partagez avec des médecins apparaîtront ici.' : 'Records you share with doctors will appear here.';
  String get revokeAccess => _fr ? 'Révoquer' : 'Revoke';
  String get revokeConfirm => _fr ? 'Révoquer l\'accès au dossier partagé avec' : 'Revoke access to the record shared with';
  String get accessRevoked => _fr ? 'Accès révoqué' : 'Access revoked';
  String get sharedWith => _fr ? 'Partagé avec' : 'Shared with';

  // ── Change password ────────────────────────────────────────────────────────
  String get currentPassword => _fr ? 'Mot de passe actuel' : 'Current password';
  String get newPassword => _fr ? 'Nouveau mot de passe' : 'New password';
  String get confirmNewPassword => _fr ? 'Confirmer le nouveau mot de passe' : 'Confirm new password';
  String get passwordChanged => _fr ? 'Mot de passe mis à jour avec succès' : 'Password updated successfully';
  String get passwordTooShort => _fr ? 'Le mot de passe doit comporter au moins 6 caractères' : 'Password must be at least 6 characters';
  String get passwordsDoNotMatch => _fr ? 'Les mots de passe ne correspondent pas' : 'Passwords do not match';
  String get wrongCurrentPassword => _fr ? 'Mot de passe actuel incorrect' : 'Current password is incorrect';
  String get signInToChangePassword => _fr ? 'Connectez-vous pour changer votre mot de passe' : 'Sign in to change your password';

  // ── Doctor profile ─────────────────────────────────────────────────────────
  String get doctorProfileTitle => _fr ? 'Profil médecin' : 'Doctor profile';
  String get editProfile => _fr ? 'Modifier le profil' : 'Edit profile';
  String get manageSchedule => _fr ? "Gérer l'agenda" : 'Manage schedule';
  String get signOutConfirm => _fr ? 'Êtes-vous sûr de vouloir vous déconnecter ?' : 'Are you sure you want to sign out?';
  String get availability => _fr ? 'Disponibilité' : 'Availability';
  String get availableForAppointments => _fr ? 'Disponible pour les rendez-vous' : 'Available for appointments';
  String get notAcceptingAppointments => _fr ? "N'accepte pas de rendez-vous" : 'Not accepting appointments';
  String get profileDetails => _fr ? 'Détails du profil' : 'Profile details';

  // ── Doctor home ────────────────────────────────────────────────────────────
  String get upcomingAppointments => _fr ? 'Rendez-vous à venir' : 'Upcoming appointments';
  String get noUpcomingAppointmentsDoc => _fr ? 'Aucun rendez-vous à venir.' : 'No upcoming appointments.';
  String appointmentsCount(int n) => _fr
      ? '$n rendez-vous'
      : '$n appointment${n == 1 ? '' : 's'}';
  String get totalLabel => _fr ? 'Total' : 'Total';
  String get upcomingLabel => _fr ? 'À venir' : 'Upcoming';

  // ── Discover / Doctor details ──────────────────────────────────────────────
  String get doctorSpecialtyOrClinic => _fr ? 'Médecin, spécialité ou clinique' : 'Doctor, specialty, or clinic';
  String get useLocationToImprove => _fr ? 'Utiliser votre position pour les soins à proximité' : 'Use your location to improve nearby care';
  String get locating => _fr ? 'Localisation' : 'Locating';
  String get use => _fr ? 'Utiliser' : 'Use';
  String get savedLabel => _fr ? 'Enregistrés' : 'Saved';
  String get noDoctorsFound => _fr ? 'Aucun médecin trouvé. Essayez une autre recherche.' : 'No doctors found. Try another search.';
  String get noSavedDoctors => _fr ? 'Aucun médecin enregistré' : 'No saved doctors yet';
  String get tapBookmarkToSave => _fr ? "Appuyez sur l'icône de signet pour enregistrer un médecin." : 'Tap the bookmark icon on any doctor profile to save them.';
  String get locationPermissionRequired => _fr ? 'Autorisation de localisation requise' : 'Location permission is required';
  String get locationActive => _fr ? 'Position active :' : 'Location active:';
  String get removeFromSaved => _fr ? 'Retirer des enregistrés' : 'Remove from saved';
  String get saveDoctor => _fr ? 'Enregistrer le médecin' : 'Save doctor';
  String get rating => _fr ? 'Évaluation' : 'Rating';
  String get noReviews => _fr ? 'Aucun avis' : 'No reviews';
  String get experience => _fr ? 'Expérience' : 'Experience';
  String get distance => _fr ? 'Distance' : 'Distance';
  String get nextAvailability => _fr ? 'Prochaine disponibilité' : 'Next availability';
  String get bookAnAppointment => _fr ? 'Prendre rendez-vous' : 'Book an appointment';
  String get messageDoctor => _fr ? 'Envoyer un message' : 'Message doctor';
  String get signInToMessage => _fr ? "Connectez-vous pour envoyer des messages aux médecins" : 'Sign in to message doctors';
  String get signInToSave => _fr ? "Connectez-vous pour enregistrer des médecins" : 'Sign in to save doctors';
  String get removedFromSaved => _fr ? 'Retiré des enregistrés' : 'Removed from saved';
  String savedDoctorMsg(String name) => _fr ? '$name enregistré(e)' : '$name saved';
  String nearbyDoctorCount(int n) => _fr ? '$n médecin${n > 1 ? 's' : ''} à proximité' : '$n doctor${n == 1 ? '' : 's'} near you';
  String savedDoctorCount(int n) => _fr ? '$n médecin${n > 1 ? 's' : ''} enregistré${n > 1 ? 's' : ''}' : '$n saved doctor${n == 1 ? '' : 's'}';

  // ── Patients (doctor) ──────────────────────────────────────────────────────
  String get searchPatients => _fr ? 'Rechercher des patients par nom ou e-mail' : 'Search patients by name or email';
  String get noPatientsYet => _fr ? 'Aucun patient pour le moment' : 'No patients yet';
  String get patientsEmptyMsg => _fr ? 'Les patients qui prennent rendez-vous avec vous apparaîtront ici.' : 'Patients who book appointments with you will appear here.';
  String get messagePatient => _fr ? 'Message au patient' : 'Message patient';
  String get addConsultationNote => _fr ? 'Ajouter une note de consultation' : 'Add consultation note';
  String get prescribeMedication => _fr ? 'Prescrire un médicament' : 'Prescribe medication';
  String get noRecordsForPatient => _fr ? 'Aucun dossier disponible pour ce patient.' : 'No records available for this patient.';
  String get noMedicationsOnRecord => _fr ? 'Aucun médicament enregistré.' : 'No medications on record.';
  String get recordType => _fr ? 'Type de dossier' : 'Record type';
  String get titleLabel => _fr ? 'Titre' : 'Title';
  String get notesSummary => _fr ? 'Notes / résumé' : 'Notes / summary';
  String get saveNote => _fr ? 'Enregistrer la note' : 'Save note';
  String get enterATitle => _fr ? 'Entrez un titre' : 'Enter a title';
  String get noteSaved => _fr ? 'Note enregistrée dans le dossier patient' : 'Note saved to patient record';
  String get sendPrescription => _fr ? 'Envoyer la prescription' : 'Send prescription';
  String get enterMedNameAndDosage => _fr ? 'Entrez le nom du médicament et le dosage' : 'Enter medication name and dosage';
  String get prescriptionSentTo => _fr ? 'Prescription envoyée à' : 'Prescription sent to';
  String patientCount(int n) => _fr ? '$n patient${n > 1 ? 's' : ''}' : '$n patient${n == 1 ? '' : 's'}';
  String noMatchingPatients(String q) => _fr ? 'Aucun patient ne correspond à "$q"' : 'No patients match "$q"';

  // ── Chat ───────────────────────────────────────────────────────────────────
  String get noMessagesYet => _fr ? 'Pas encore de messages' : 'No messages yet';
  String get visitDoctorProfile => _fr ? "Visitez le profil d'un médecin pour démarrer une conversation." : "Visit a doctor's profile to start a conversation.";
  String sayHelloTo(String name) => _fr ? 'Dites bonjour à $name !' : 'Say hello to $name!';
  String get messagePlaceholder => 'Message…';
  String get recording => _fr ? 'Enregistrement' : 'Recording';
  String get micPermissionRequired => _fr ? 'Autorisation du microphone requise' : 'Microphone permission is required';
  String get failedToSend => _fr ? "Échec de l'envoi :" : 'Failed to send:';
  String get failedToSendVoice => _fr ? "Échec de l'envoi de la note vocale :" : 'Failed to send voice note:';
  String get stop => _fr ? 'Arrêter' : 'Stop';

  // ── Doctor my schedule screen ──────────────────────────────────────────────
  String get mySchedule => _fr ? 'Mon agenda' : 'My schedule';
  String get acceptingAppointments => _fr ? 'Accepte des rendez-vous' : 'Accepting appointments';
  String get turnOffToPause => _fr ? 'Désactivez pour mettre en pause les nouvelles réservations.' : 'Turn off to pause all new bookings.';
  String get weeklySchedule => _fr ? 'Emploi du temps hebdomadaire' : 'Weekly schedule';
  String get setWorkingHours => _fr ? 'Définissez vos horaires de travail pour chaque jour.' : 'Set your working hours for each day.';
  String get allWeek => _fr ? 'Toute la semaine' : 'All Week';
  String get weekdays => _fr ? 'Jours ouvrables' : 'Weekdays';
  String get noActiveDays => _fr ? 'Aucun jour actif' : 'No active days';
  String get unavailable => _fr ? 'Indisponible' : 'Unavailable';
  String get scheduleNote => _fr ? 'Les patients ne peuvent réserver que dans vos heures actives.' : 'Patients can only book slots within your active hours. You can update your schedule at any time.';
  String get saveSchedule => _fr ? "Enregistrer l'agenda" : 'Save schedule';
  String get scheduleSaved => _fr ? "Agenda enregistré" : 'Schedule saved';
  String daysCount(int n) => _fr ? '$n jour${n > 1 ? 's' : ''}' : '$n day${n == 1 ? '' : 's'}';

  // ── Book visit ─────────────────────────────────────────────────────────────
  String get bookAVisitTitle => _fr ? 'Prendre rendez-vous' : 'Book a visit';
  String get chooseCareYouNeed => _fr ? 'Choisissez le soin dont vous avez besoin' : 'Choose the care you need';
  String get selectDoctorPrompt => _fr ? 'Sélectionnez un médecin pour voir les horaires disponibles.' : 'Select a doctor to view available times for a clinic visit or video consultation.';
  String get searchDoctorsOrSpecialties => _fr ? 'Chercher médecins ou spécialités' : 'Search doctors or specialties';
  String get availableDoctors => _fr ? 'Médecins disponibles' : 'Available doctors';
  String get viewAvailableTimes => _fr ? 'Voir les horaires disponibles' : 'View available times';

  // ── Record access / privacy ────────────────────────────────────────────────
  String get recordPrivacyTitle => _fr ? 'Confidentialité des dossiers' : 'Record Privacy';
  String get recordPrivacySubtitle => _fr ? 'Contrôlez quels médecins peuvent consulter vos dossiers médicaux.' : 'Control which doctors can view your medical records.';
  String get doctorAccess => _fr ? 'Accès des médecins' : 'Doctor Access';
  String get pendingAccessRequests => _fr ? 'Demandes en attente' : 'Pending Requests';
  String get noPendingRequests => _fr ? 'Aucune demande en attente' : 'No pending requests';
  String get noDoctorAccess => _fr ? "Aucun médecin n'a encore eu accès à vos dossiers." : 'No doctors have accessed your records yet.';
  String get accessGranted => _fr ? 'Accès accordé' : 'Access granted';
  String get accessBlocked => _fr ? 'Accès bloqué' : 'Access blocked';
  String get accessRequested => _fr ? 'Accès demandé' : 'Access requested';
  String get blockAccess => _fr ? "Bloquer l'accès" : 'Block access';
  String get grantAccess => _fr ? "Accorder l'accès" : 'Grant access';
  String get requestAccess => _fr ? "Demander l'accès" : 'Request access';
  String get acceptRequest => _fr ? 'Accepter' : 'Accept';
  String get rejectRequest => _fr ? 'Rejeter' : 'Reject';
  String get accessRequestSent => _fr ? 'Demande envoyée au patient' : 'Access request sent to patient';
  String get accessRequestPending => _fr ? 'En attente de la réponse du patient' : 'Waiting for patient approval';
  String get recordsAccessBlocked => _fr ? "Ce patient a bloqué l'accès à ses dossiers médicaux." : 'This patient has blocked access to their medical records.';
  String accessUpdated(String name) => _fr ? "Accès mis à jour pour Dr. $name" : 'Access updated for Dr. $name';
  String requestFrom(String name) => _fr ? 'Dr. $name demande à consulter vos dossiers médicaux.' : 'Dr. $name is requesting access to view your medical records.';
  String get wantsToViewRecords => _fr ? 'souhaite consulter vos dossiers médicaux' : 'wants to view your medical records';
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppL10n> load(Locale locale) async => AppL10n(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}
