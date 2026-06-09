// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fillForm => 'Fill Form';

  @override
  String get administration => 'Administration';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get welcomeBackWaving => 'Welcome back 👋';

  @override
  String get language => 'Language';

  @override
  String get submit => 'Submit';

  @override
  String get name => 'Full Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get noResponsesYet => 'No responses yet';

  @override
  String get adminPassword => 'Admin Password';

  @override
  String get password => 'Password';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get unlock => 'Unlock';

  @override
  String get cancel => 'Cancel';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get formStacker => 'FormStacker';

  @override
  String get navigationAndSettings => 'Navigation & Settings';

  @override
  String get fillAndManage => 'Fill out and manage form responses';

  @override
  String get createAndSubmit => 'Create and submit a new form';

  @override
  String get manageFormsAndUsers => 'Manage forms, users and settings';

  @override
  String get overview => 'Overview';

  @override
  String get viewAll => 'View all';

  @override
  String get totalResponses => 'Total Responses';

  @override
  String get questionsAnswered => 'Questions Answered';

  @override
  String get pendingResponses => 'Pending Responses';

  @override
  String get keepTrackBanner =>
      'Keep track of your forms and responses all in one place.';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Please enter a valid email address';

  @override
  String get selectDob => 'Please select your date of birth';

  @override
  String calculatedAge(int age) {
    return 'Calculated Age: $age';
  }

  @override
  String get yearsOfExperience => 'Years of Experience';

  @override
  String get selfRating => 'Self-Rating';

  @override
  String get profileDetails => 'Profile Details';

  @override
  String get profilePhoto => 'Profile Photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get resumePdf => 'Resume (PDF)';

  @override
  String get uploadResume => 'Upload Resume';

  @override
  String get fileSizeError => 'File size must be under 5MB';

  @override
  String get languagesKnown => 'Languages Known';

  @override
  String get physicalAttributes => 'Physical Attributes';

  @override
  String get height => 'Height';

  @override
  String get feet => 'Feet';

  @override
  String get inches => 'Inches';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get agreeTerms => 'I agree to the terms and conditions';

  @override
  String get acceptTermsError => 'You must accept terms to continue';

  @override
  String get responseSubmitted => 'Response submitted!';

  @override
  String get cameraPermissionRequired =>
      'Camera permission is required to capture photos using your camera.';

  @override
  String get photosPermissionRequired =>
      'Photos permission is required to select images from your gallery.';

  @override
  String get storagePermissionRequired =>
      'Storage permission is required to select images from your gallery.';

  @override
  String get resumePermissionRequired =>
      'Storage permission is required to select and upload your resume.';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get unlockAdmin => 'Unlock Administration';

  @override
  String get enterPasswordToAccess => 'Enter password to access form responses';

  @override
  String get pleaseEnterPassword => 'Please enter the admin password';

  @override
  String get searchResponses => 'Search responses...';

  @override
  String ageAndExperience(int age, int exp) {
    return 'Age: $age | Experience: $exp years';
  }

  @override
  String languagesLabel(String langs) {
    return 'Languages: $langs';
  }

  @override
  String get noPhotoUploaded => 'No photo uploaded';

  @override
  String get viewPhoto => 'View Photo';

  @override
  String get noResumeUploaded => 'No resume uploaded';

  @override
  String get viewResume => 'View Resume';

  @override
  String get viewDetails => 'View Details';

  @override
  String nameLabel(String name) {
    return 'Name: $name';
  }

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String dobLabel(String dob) {
    return 'Date of Birth: $dob';
  }

  @override
  String ageLabel(int age) {
    return 'Age: $age';
  }

  @override
  String genderLabel(String gender) {
    return 'Gender: $gender';
  }

  @override
  String experienceLabel(int exp) {
    return 'Experience: $exp years';
  }

  @override
  String selfRatingLabel(int rating) {
    return 'Self-Rating: $rating/5';
  }

  @override
  String languagesKnownLabel(String langs) {
    return 'Languages Known: $langs';
  }

  @override
  String heightLabel(String height) {
    return 'Height: $height';
  }

  @override
  String weightLabel(String weight) {
    return 'Weight: $weight kg';
  }

  @override
  String get files => 'Files';

  @override
  String get profilePhotoLabel => 'Profile Photo:';

  @override
  String get resumeLabel => 'Resume:';

  @override
  String get close => 'Close';

  @override
  String get incorrectPassword => 'Incorrect password. Access denied.';

  @override
  String get formResponses => 'Form Responses';

  @override
  String responseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '$count response$_temp0';
  }

  @override
  String get incorrectPasswordShort => 'Incorrect password';

  @override
  String get setAdminPassword => 'Set admin password';

  @override
  String get newPassword => 'New password';

  @override
  String get set => 'Set';

  @override
  String get none => 'None';

  @override
  String get agreed => 'Agreed';

  @override
  String get notAgreed => 'Not agreed';

  @override
  String get ratingStars => 'Rating: ';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get savesBattery => 'Saves battery and reduces eye strain';

  @override
  String get brightAndClear => 'Bright and clear display mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get receiveAlerts => 'Receive instant alerts on your device';

  @override
  String get emailDigests => 'Email Digests';

  @override
  String get receiveDigests => 'Receive a weekly summary of form activity';

  @override
  String get about => 'About';

  @override
  String get formStackerApp => 'FormStacker App';

  @override
  String get appVersion => 'Version 1.0.0 (Build 4)';

  @override
  String get developerTools => 'Developer Tools';

  @override
  String get showAdvanced => 'Show advanced settings and debug options';

  @override
  String get devModeEnabled => 'Developer mode is already enabled.';

  @override
  String get noNotificationsYet => 'No notifications yet.';

  @override
  String get reviewMetrics =>
      'Review your response and submission metrics in one place.';

  @override
  String get keyMetrics => 'Key metrics';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get userInformationForm => 'User Information Form';

  @override
  String get pleaseProvideInfo => 'Please provide your information below';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get dateAgeInfo => 'Date & Age Information';

  @override
  String calculatedAgeLabel(String age) {
    return 'Calculated Age: $age years';
  }

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderPreferNotToSay => 'Prefer not to say';

  @override
  String get location => 'Location';

  @override
  String get selectStateUtHint => 'Select your state or union territory';

  @override
  String get city => 'City';

  @override
  String get chooseStateFirst => 'Choose a state first to search cities';

  @override
  String get selectStateSuggestions =>
      'Please select a state to see city suggestions.';

  @override
  String get langHindi => 'Hindi';

  @override
  String get langEnglish => 'English';

  @override
  String get langBengali => 'Bengali';

  @override
  String get langFrench => 'French';

  @override
  String get langJapanese => 'Japanese';

  @override
  String get enterWholeFeet => 'Enter whole feet';

  @override
  String get feetLimit => 'Feet must be between 1 and 8';

  @override
  String get enterWholeInches => 'Enter whole inches';

  @override
  String get inchesLimit => 'Inches must be between 0 and 11';

  @override
  String get enterValidWeight => 'Enter a valid weight';

  @override
  String get weightMinLimit => 'Weight must be at least 20 kg';

  @override
  String get weightMaxLimit => 'Weight must be at most 300 kg';

  @override
  String get professionalExperience => 'Professional Experience';

  @override
  String get yearsOfExperienceHint => 'Years of experience';

  @override
  String yearsLabel(String years) {
    return '$years years';
  }

  @override
  String get rating => 'Rating';

  @override
  String get agreements => 'Agreements';

  @override
  String get selectAtLeastOneLanguage => 'Please select at least one language';

  @override
  String get demographics => 'Demographics';

  @override
  String get delete => 'Delete';

  @override
  String get deleteResponse => 'Delete Response';

  @override
  String confirmDeleteMessage(String name) {
    return 'Are you sure you want to delete the response from $name? This action cannot be undone.';
  }

  @override
  String get responseDeleted => 'Response deleted';
}
