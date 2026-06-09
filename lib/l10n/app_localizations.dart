import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @fillForm.
  ///
  /// In en, this message translates to:
  /// **'Fill Form'**
  String get fillForm;

  /// No description provided for @administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @welcomeBackWaving.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcomeBackWaving;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @noResponsesYet.
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get noResponsesYet;

  /// No description provided for @adminPassword.
  ///
  /// In en, this message translates to:
  /// **'Admin Password'**
  String get adminPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @formStacker.
  ///
  /// In en, this message translates to:
  /// **'FormStacker'**
  String get formStacker;

  /// No description provided for @navigationAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Navigation & Settings'**
  String get navigationAndSettings;

  /// No description provided for @fillAndManage.
  ///
  /// In en, this message translates to:
  /// **'Fill out and manage form responses'**
  String get fillAndManage;

  /// No description provided for @createAndSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create and submit a new form'**
  String get createAndSubmit;

  /// No description provided for @manageFormsAndUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage forms, users and settings'**
  String get manageFormsAndUsers;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @totalResponses.
  ///
  /// In en, this message translates to:
  /// **'Total Responses'**
  String get totalResponses;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions Answered'**
  String get questionsAnswered;

  /// No description provided for @pendingResponses.
  ///
  /// In en, this message translates to:
  /// **'Pending Responses'**
  String get pendingResponses;

  /// No description provided for @keepTrackBanner.
  ///
  /// In en, this message translates to:
  /// **'Keep track of your forms and responses all in one place.'**
  String get keepTrackBanner;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterEmail;

  /// No description provided for @selectDob.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get selectDob;

  /// No description provided for @calculatedAge.
  ///
  /// In en, this message translates to:
  /// **'Calculated Age: {age}'**
  String calculatedAge(int age);

  /// No description provided for @yearsOfExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of Experience'**
  String get yearsOfExperience;

  /// No description provided for @selfRating.
  ///
  /// In en, this message translates to:
  /// **'Self-Rating'**
  String get selfRating;

  /// No description provided for @profileDetails.
  ///
  /// In en, this message translates to:
  /// **'Profile Details'**
  String get profileDetails;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhoto;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @resumePdf.
  ///
  /// In en, this message translates to:
  /// **'Resume (PDF)'**
  String get resumePdf;

  /// No description provided for @uploadResume.
  ///
  /// In en, this message translates to:
  /// **'Upload Resume'**
  String get uploadResume;

  /// No description provided for @fileSizeError.
  ///
  /// In en, this message translates to:
  /// **'File size must be under 5MB'**
  String get fileSizeError;

  /// No description provided for @languagesKnown.
  ///
  /// In en, this message translates to:
  /// **'Languages Known'**
  String get languagesKnown;

  /// No description provided for @physicalAttributes.
  ///
  /// In en, this message translates to:
  /// **'Physical Attributes'**
  String get physicalAttributes;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @feet.
  ///
  /// In en, this message translates to:
  /// **'Feet'**
  String get feet;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'Inches'**
  String get inches;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms and conditions'**
  String get agreeTerms;

  /// No description provided for @acceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'You must accept terms to continue'**
  String get acceptTermsError;

  /// No description provided for @responseSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Response submitted!'**
  String get responseSubmitted;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to capture photos using your camera.'**
  String get cameraPermissionRequired;

  /// No description provided for @photosPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Photos permission is required to select images from your gallery.'**
  String get photosPermissionRequired;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to select images from your gallery.'**
  String get storagePermissionRequired;

  /// No description provided for @resumePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage permission is required to select and upload your resume.'**
  String get resumePermissionRequired;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @unlockAdmin.
  ///
  /// In en, this message translates to:
  /// **'Unlock Administration'**
  String get unlockAdmin;

  /// No description provided for @enterPasswordToAccess.
  ///
  /// In en, this message translates to:
  /// **'Enter password to access form responses'**
  String get enterPasswordToAccess;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter the admin password'**
  String get pleaseEnterPassword;

  /// No description provided for @searchResponses.
  ///
  /// In en, this message translates to:
  /// **'Search responses...'**
  String get searchResponses;

  /// No description provided for @ageAndExperience.
  ///
  /// In en, this message translates to:
  /// **'Age: {age} | Experience: {exp} years'**
  String ageAndExperience(int age, int exp);

  /// No description provided for @languagesLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages: {langs}'**
  String languagesLabel(String langs);

  /// No description provided for @noPhotoUploaded.
  ///
  /// In en, this message translates to:
  /// **'No photo uploaded'**
  String get noPhotoUploaded;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View Photo'**
  String get viewPhoto;

  /// No description provided for @noResumeUploaded.
  ///
  /// In en, this message translates to:
  /// **'No resume uploaded'**
  String get noResumeUploaded;

  /// No description provided for @viewResume.
  ///
  /// In en, this message translates to:
  /// **'View Resume'**
  String get viewResume;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name: {name}'**
  String nameLabel(String name);

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailLabel(String email);

  /// No description provided for @dobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth: {dob}'**
  String dobLabel(String dob);

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age: {age}'**
  String ageLabel(int age);

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender: {gender}'**
  String genderLabel(String gender);

  /// No description provided for @experienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience: {exp} years'**
  String experienceLabel(int exp);

  /// No description provided for @selfRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Self-Rating: {rating}/5'**
  String selfRatingLabel(int rating);

  /// No description provided for @languagesKnownLabel.
  ///
  /// In en, this message translates to:
  /// **'Languages Known: {langs}'**
  String languagesKnownLabel(String langs);

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height: {height}'**
  String heightLabel(String height);

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight: {weight} kg'**
  String weightLabel(String weight);

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @profilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo:'**
  String get profilePhotoLabel;

  /// No description provided for @resumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Resume:'**
  String get resumeLabel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Access denied.'**
  String get incorrectPassword;

  /// No description provided for @formResponses.
  ///
  /// In en, this message translates to:
  /// **'Form Responses'**
  String get formResponses;

  /// No description provided for @responseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} response{count, plural, =1{} other{s}}'**
  String responseCount(int count);

  /// No description provided for @incorrectPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password'**
  String get incorrectPasswordShort;

  /// No description provided for @setAdminPassword.
  ///
  /// In en, this message translates to:
  /// **'Set admin password'**
  String get setAdminPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @agreed.
  ///
  /// In en, this message translates to:
  /// **'Agreed'**
  String get agreed;

  /// No description provided for @notAgreed.
  ///
  /// In en, this message translates to:
  /// **'Not agreed'**
  String get notAgreed;

  /// No description provided for @ratingStars.
  ///
  /// In en, this message translates to:
  /// **'Rating: '**
  String get ratingStars;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @savesBattery.
  ///
  /// In en, this message translates to:
  /// **'Saves battery and reduces eye strain'**
  String get savesBattery;

  /// No description provided for @brightAndClear.
  ///
  /// In en, this message translates to:
  /// **'Bright and clear display mode'**
  String get brightAndClear;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'Receive instant alerts on your device'**
  String get receiveAlerts;

  /// No description provided for @emailDigests.
  ///
  /// In en, this message translates to:
  /// **'Email Digests'**
  String get emailDigests;

  /// No description provided for @receiveDigests.
  ///
  /// In en, this message translates to:
  /// **'Receive a weekly summary of form activity'**
  String get receiveDigests;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @formStackerApp.
  ///
  /// In en, this message translates to:
  /// **'FormStacker App'**
  String get formStackerApp;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0 (Build 4)'**
  String get appVersion;

  /// No description provided for @developerTools.
  ///
  /// In en, this message translates to:
  /// **'Developer Tools'**
  String get developerTools;

  /// No description provided for @showAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Show advanced settings and debug options'**
  String get showAdvanced;

  /// No description provided for @devModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Developer mode is already enabled.'**
  String get devModeEnabled;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get noNotificationsYet;

  /// No description provided for @reviewMetrics.
  ///
  /// In en, this message translates to:
  /// **'Review your response and submission metrics in one place.'**
  String get reviewMetrics;

  /// No description provided for @keyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Key metrics'**
  String get keyMetrics;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @userInformationForm.
  ///
  /// In en, this message translates to:
  /// **'User Information Form'**
  String get userInformationForm;

  /// No description provided for @pleaseProvideInfo.
  ///
  /// In en, this message translates to:
  /// **'Please provide your information below'**
  String get pleaseProvideInfo;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @dateAgeInfo.
  ///
  /// In en, this message translates to:
  /// **'Date & Age Information'**
  String get dateAgeInfo;

  /// No description provided for @calculatedAgeLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculated Age: {age} years'**
  String calculatedAgeLabel(String age);

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @selectStateUtHint.
  ///
  /// In en, this message translates to:
  /// **'Select your state or union territory'**
  String get selectStateUtHint;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @chooseStateFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a state first to search cities'**
  String get chooseStateFirst;

  /// No description provided for @selectStateSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Please select a state to see city suggestions.'**
  String get selectStateSuggestions;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get langHindi;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langBengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get langBengali;

  /// No description provided for @langFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get langFrench;

  /// No description provided for @langJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langJapanese;

  /// No description provided for @enterWholeFeet.
  ///
  /// In en, this message translates to:
  /// **'Enter whole feet'**
  String get enterWholeFeet;

  /// No description provided for @feetLimit.
  ///
  /// In en, this message translates to:
  /// **'Feet must be between 1 and 8'**
  String get feetLimit;

  /// No description provided for @enterWholeInches.
  ///
  /// In en, this message translates to:
  /// **'Enter whole inches'**
  String get enterWholeInches;

  /// No description provided for @inchesLimit.
  ///
  /// In en, this message translates to:
  /// **'Inches must be between 0 and 11'**
  String get inchesLimit;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get enterValidWeight;

  /// No description provided for @weightMinLimit.
  ///
  /// In en, this message translates to:
  /// **'Weight must be at least 20 kg'**
  String get weightMinLimit;

  /// No description provided for @weightMaxLimit.
  ///
  /// In en, this message translates to:
  /// **'Weight must be at most 300 kg'**
  String get weightMaxLimit;

  /// No description provided for @professionalExperience.
  ///
  /// In en, this message translates to:
  /// **'Professional Experience'**
  String get professionalExperience;

  /// No description provided for @yearsOfExperienceHint.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsOfExperienceHint;

  /// No description provided for @yearsLabel.
  ///
  /// In en, this message translates to:
  /// **'{years} years'**
  String yearsLabel(String years);

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @agreements.
  ///
  /// In en, this message translates to:
  /// **'Agreements'**
  String get agreements;

  /// No description provided for @selectAtLeastOneLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one language'**
  String get selectAtLeastOneLanguage;

  /// No description provided for @demographics.
  ///
  /// In en, this message translates to:
  /// **'Demographics'**
  String get demographics;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteResponse.
  ///
  /// In en, this message translates to:
  /// **'Delete Response'**
  String get deleteResponse;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the response from {name}? This action cannot be undone.'**
  String confirmDeleteMessage(String name);

  /// No description provided for @responseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Response deleted'**
  String get responseDeleted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
