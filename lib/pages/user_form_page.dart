import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../l10n/app_localizations.dart';
import '../models/form_response.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../store/response_store.dart';
import '../widgets/app_drawer.dart';
import '../widgets/sync_status_bar.dart';

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _primaryColor = const Color(0xFF673AB7);
  final _accentColor = const Color(0xFF7C4DFF);

  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  final Map<String, List<String>> _citiesByState = {
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur'],
    'Arunachal Pradesh': ['Itanagar', 'Tawang', 'Naharlagun'],
    'Assam': ['Guwahati', 'Dibrugarh', 'Silchar'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur'],
    'Chhattisgarh': ['Raipur', 'Bhilai', 'Durg'],
    'Goa': ['Panaji', 'Vasco da Gama', 'Margao'],
    'Gujarat': ['Ahmedabad', 'Vadodara', 'Surat'],
    'Haryana': ['Gurugram', 'Faridabad', 'Panipat'],
    'Himachal Pradesh': ['Shimla', 'Dharamshala', 'Solan'],
    'Jharkhand': ['Ranchi', 'Jamshedpur', 'Dhanbad'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangalore'],
    'Kerala': ['Thiruvananthapuram', 'Kochi', 'Kozhikode'],
    'Madhya Pradesh': ['Bhopal', 'Indore', 'Gwalior'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur'],
    'Manipur': ['Imphal', 'Thoubal', 'Churachandpur'],
    'Meghalaya': ['Shillong', 'Tura', 'Nongpoh'],
    'Mizoram': ['Aizawl', 'Lunglei', 'Saiha'],
    'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar'],
    'Rajasthan': ['Jaipur', 'Udaipur', 'Jodhpur'],
    'Sikkim': ['Gangtok', 'Geyzing', 'Namchi'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai'],
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad'],
    'Tripura': ['Agartala', 'Udaipur', 'Khowai'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Varanasi'],
    'Uttarakhand': ['Dehradun', 'Nainital', 'Haridwar'],
    'West Bengal': ['Kolkata', 'Darjeeling', 'Siliguri'],
    'Andaman and Nicobar Islands': ['Port Blair'],
    'Chandigarh': ['Chandigarh'],
    'Dadra and Nagar Haveli and Daman and Diu': ['Daman', 'Diu', 'Silvassa'],
    'Delhi': ['New Delhi', 'Dwarka', 'Rohini'],
    'Jammu and Kashmir': ['Srinagar', 'Jammu', 'Anantnag'],
    'Ladakh': ['Leh', 'Kargil'],
    'Lakshadweep': ['Kavaratti'],
    'Puducherry': ['Puducherry', 'Mahe', 'Karaikal'],
  };

  int _calculatedAge = 0;
  DateTime? _selectedDob;

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;
      final dob = values['dob'] as DateTime;
      final calculatedAge = _calculateAge(dob);

      final photoPath = values['photo'] as String?;
      final resumePath = values['resume'] as String?;
      final response = FormResponse(
        name: values['name'],
        email: values['email'],
        dob: dob,
        age: calculatedAge,
        gender: values['gender'] as String,
        yearsOfExperience: values['yearsOfExperience'] as int,
        rating: values['rating'] as int,
        photoPath: photoPath,
        resumePath: resumePath,
        languages:
            (values['languages'] as List<dynamic>?)?.cast<String>() ??
            <String>[],
        heightFeet: int.tryParse(values['heightFeet']?.toString() ?? '') ?? 0,
        heightInches:
            int.tryParse(values['heightInches']?.toString() ?? '') ?? 0,
        weight: double.tryParse(values['weight']?.toString() ?? '') ?? 0.0,
        agreed: (values['agreed'] as bool?) ?? false,
        createdAt: DateTime.now(),
      );

      // Show submission overlay
      final online = ConnectivityService().isOnline.value;
      _showSubmissionOverlay(online);

      final savedResponse = await ResponseStore().add(response);
      if (online) {
        await SyncService().syncResponse(savedResponse);
      }

      // Wait for overlay animation then navigate back
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      Navigator.of(context).pop(); // dismiss overlay
      Navigator.of(context).pop(); // navigate back
    }
  }

  void _showSubmissionOverlay(bool isOnline) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => _SubmissionOverlay(isOnline: isOnline),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.fillForm)),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: SingleChildScrollView(
        child: Column(
          children: [
            // Purple gradient banner header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryColor, _accentColor],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.userInformationForm,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.pleaseProvideInfo,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal Information Section
                    _buildSectionTitle(l10n.personalInformation),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderTextField(
                        name: 'name',
                        decoration: InputDecoration(
                          labelText: l10n.name,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.person, color: _primaryColor),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(2),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'email',
                        decoration: InputDecoration(
                          labelText: l10n.emailAddress,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.email, color: _primaryColor),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(
                            errorText: l10n.enterEmail,
                          ),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Date & Age Section
                    _buildSectionTitle(l10n.dateAgeInfo),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderDateTimePicker(
                        name: 'dob',
                        inputType: InputType.date,
                        decoration: InputDecoration(
                          labelText: l10n.dateOfBirth,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: _primaryColor,
                          ),
                        ),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDob = value;
                              _calculatedAge = _calculateAge(value);
                            });
                          }
                        },
                        validator: FormBuilderValidators.required(),
                      ),
                      if (_selectedDob != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: _primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  l10n.calculatedAgeLabel(_calculatedAge.toString()),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: _primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 32),
                    // Demographics Section
                    _buildSectionTitle(l10n.demographics),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderRadioGroup<String>(
                        name: 'gender',
                        decoration: InputDecoration(
                          labelText: l10n.gender,
                          border: InputBorder.none,
                        ),
                        options: [
                          FormBuilderFieldOption(value: 'Male', child: Text(l10n.genderMale)),
                          FormBuilderFieldOption(value: 'Female', child: Text(l10n.genderFemale)),
                          FormBuilderFieldOption(value: 'Other', child: Text(l10n.genderOther)),
                          FormBuilderFieldOption(value: 'Prefer not to say', child: Text(l10n.genderPreferNotToSay)),
                        ],
                        validator: FormBuilderValidators.required(),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Location Section
                    _buildSectionTitle(l10n.location),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderDropdown<String>(
                        name: 'state',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.map, color: _primaryColor),
                        ),
                        hint: Text(
                          l10n.selectStateUtHint,
                        ),
                        items: _states
                            .map(
                              (state) => DropdownMenuItem(
                                value: state,
                                child: Text(state),
                              ),
                            )
                            .toList(),
                        validator: FormBuilderValidators.required(),
                        onChanged: (value) {
                          setState(() {});
                          _formKey.currentState?.fields['city']?.didChange(
                            null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FormBuilderField<String>(
                        name: 'city',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        builder: (field) {
                          final stateValue =
                              _formKey.currentState?.fields['state']?.value
                                  as String?;
                          final options = stateValue != null
                              ? _citiesByState[stateValue] ?? const <String>[]
                              : const <String>[];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Autocomplete<String>(
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (stateValue == null ||
                                          textEditingValue.text.isEmpty) {
                                        return const Iterable<String>.empty();
                                      }
                                      return options.where(
                                        (city) => city.toLowerCase().contains(
                                          textEditingValue.text.toLowerCase(),
                                        ),
                                      );
                                    },
                                onSelected: (selection) {
                                  field.didChange(selection);
                                },
                                fieldViewBuilder:
                                    (
                                      context,
                                      textEditingController,
                                      focusNode,
                                      onFieldSubmitted,
                                    ) {
                                      textEditingController.text =
                                          field.value ?? '';
                                      textEditingController.selection =
                                          TextSelection.fromPosition(
                                            TextPosition(
                                              offset: textEditingController
                                                  .text
                                                  .length,
                                            ),
                                          );
                                      return TextField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          labelText: l10n.city,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.location_city,
                                            color: _primaryColor,
                                          ),
                                          enabled: stateValue != null,
                                          helperText: stateValue == null
                                              ? l10n.chooseStateFirst
                                              : null,
                                          errorText: field.errorText,
                                        ),
                                        onChanged: (value) {
                                          field.didChange(value);
                                        },
                                      );
                                    },
                              ),
                              if (stateValue == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    l10n.selectStateSuggestions,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSectionTitle(l10n.profileDetails),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderField<String>(
                        name: 'photo',
                        builder: (field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.profilePhoto,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(
                                Icons.photo_camera,
                                color: _primaryColor,
                              ),
                              errorText: field.errorText,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handlePhotoPick(field, ImageSource.gallery),
                                        icon: const Icon(Icons.photo_library),
                                        label: Text(l10n.gallery),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _handlePhotoPick(field, ImageSource.camera),
                                        icon: const Icon(Icons.camera_alt),
                                        label: Text(l10n.takePhoto),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: _primaryColor,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (field.value != null && field.value!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: FileImage(File(field.value!)),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: _primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FormBuilderField<String>(
                        name: 'resume',
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final file = File(value);
                            if (file.existsSync() && file.lengthSync() > 5 * 1024 * 1024) {
                              return l10n.fileSizeError;
                            }
                          }
                          return null;
                        },
                        builder: (field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.resumePdf,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(
                                Icons.picture_as_pdf,
                                color: _primaryColor,
                              ),
                              errorText: field.errorText,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                ElevatedButton.icon(
                                  onPressed: () => _handleResumePick(field),
                                  icon: const Icon(Icons.upload_file),
                                  label: Text(l10n.uploadResume),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                if (field.value != null && field.value!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          p.basename(field.value!),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      FormBuilderFilterChips<String>(
                        name: 'languages',
                        decoration: InputDecoration(
                          labelText: l10n.languagesKnown,
                          border: InputBorder.none,
                        ),
                        options: [
                          FormBuilderChipOption(value: 'Hindi', child: Text(l10n.langHindi)),
                          FormBuilderChipOption(value: 'English', child: Text(l10n.langEnglish)),
                          FormBuilderChipOption(value: 'Bengali', child: Text(l10n.langBengali)),
                          FormBuilderChipOption(value: 'French', child: Text(l10n.langFrench)),
                          FormBuilderChipOption(value: 'Japanese', child: Text(l10n.langJapanese)),
                        ],
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(
                            1,
                            errorText: l10n.selectAtLeastOneLanguage,
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'heightFeet',
                              decoration: InputDecoration(
                                labelText: l10n.feet,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(
                                  Icons.height,
                                  color: _primaryColor,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.integer(
                                  errorText: l10n.enterWholeFeet,
                                ),
                                FormBuilderValidators.min(
                                  1,
                                  errorText: l10n.feetLimit,
                                ),
                                FormBuilderValidators.max(
                                  8,
                                  errorText: l10n.feetLimit,
                                ),
                              ]),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FormBuilderTextField(
                              name: 'heightInches',
                              decoration: InputDecoration(
                                labelText: l10n.inches,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: Icon(
                                  Icons.square_foot,
                                  color: _primaryColor,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.integer(
                                  errorText: l10n.enterWholeInches,
                                ),
                                FormBuilderValidators.min(
                                  0,
                                  errorText: l10n.inchesLimit,
                                ),
                                FormBuilderValidators.max(
                                  11,
                                  errorText: l10n.inchesLimit,
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'weight',
                        decoration: InputDecoration(
                          labelText: l10n.weightKg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(
                            Icons.monitor_weight,
                            color: _primaryColor,
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(
                            errorText: l10n.enterValidWeight,
                          ),
                          FormBuilderValidators.min(
                            20,
                            errorText: l10n.weightMinLimit,
                          ),
                          FormBuilderValidators.max(
                            300,
                            errorText: l10n.weightMaxLimit,
                          ),
                        ]),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Experience Section
                    _buildSectionTitle(l10n.professionalExperience),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderDropdown<int>(
                        name: 'yearsOfExperience',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.work, color: _primaryColor),
                        ),
                        hint: Text(l10n.yearsOfExperienceHint),
                        items: List.generate(
                          61,
                          (index) => DropdownMenuItem(
                            value: index,
                            child: Text(l10n.yearsLabel(index.toString())),
                          ),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Rating Section
                    _buildSectionTitle(l10n.rating),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderField<int>(
                        name: 'rating',
                        initialValue: 3,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        builder: (field) {
                          final value = field.value ?? 0;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (i) {
                                    final starIndex = i + 1;
                                    return IconButton(
                                      icon: Icon(
                                        starIndex <= value
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: starIndex <= value
                                            ? _primaryColor
                                            : Colors.grey[400],
                                        size: 32,
                                      ),
                                      onPressed: () => field.didChange(starIndex),
                                    );
                                  }),
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    top: 8,
                                  ),
                                  child: Text(
                                    field.errorText ?? '',
                                    style: TextStyle(color: Colors.red[600]),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Agreements Section
                    _buildSectionTitle(l10n.agreements),
                    const SizedBox(height: 16),
                    _buildFormCard([
                      FormBuilderCheckbox(
                        name: 'agreed',
                        initialValue: false,
                        title: Text(
                          l10n.agreeTerms,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        validator: FormBuilderValidators.equal(
                          true,
                          errorText: l10n.acceptTermsError,
                        ),
                      ),
                    ]),
                    const SizedBox(height: 40),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text(l10n.submit),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }

  bool _isAndroid13OrHigher() {
    if (!Platform.isAndroid) return false;
    try {
      final versionStr = Platform.operatingSystemVersion;
      for (int api = 33; api <= 40; api++) {
        if (versionStr.contains('API $api') || versionStr.contains('SDK $api')) {
          return true;
        }
      }
      for (int ver = 13; ver <= 20; ver++) {
        if (versionStr.contains('Android $ver') || versionStr.contains('version $ver')) {
          return true;
        }
      }
      final regex = RegExp(r'\b\d+\b');
      final matches = regex.allMatches(versionStr);
      for (final match in matches) {
        final value = int.tryParse(match.group(0)!);
        if (value != null) {
          if (value >= 33) return true;
          if (value >= 13 && value < 30) return true;
        }
      }
    } catch (_) {}
    return false;
  }

  void _showPermissionDialog(String explanation) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequired),
        content: Text(explanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePhotoPick(
    FormFieldState<String?> field,
    ImageSource source,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    bool isGranted = false;
    String permissionExplanation = '';

    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      isGranted = status.isGranted;
      permissionExplanation = l10n.cameraPermissionRequired;
    } else {
      if (Platform.isAndroid) {
        if (_isAndroid13OrHigher()) {
          final status = await Permission.photos.request();
          isGranted = status.isGranted;
          permissionExplanation = l10n.photosPermissionRequired;
        } else {
          final status = await Permission.storage.request();
          isGranted = status.isGranted;
          permissionExplanation = l10n.storagePermissionRequired;
        }
      } else {
        isGranted = true;
      }
    }

    if (isGranted) {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      if (image != null) {
        field.didChange(image.path);
      }
    } else {
      if (mounted) {
        _showPermissionDialog(permissionExplanation);
      }
    }
  }

  Future<void> _handleResumePick(FormFieldState<String?> field) async {
    final l10n = AppLocalizations.of(context)!;
    bool isGranted = false;
    if (Platform.isAndroid) {
      if (_isAndroid13OrHigher()) {
        // Android 13+ uses scoped storage; request manage permission for documents
        final status = await Permission.manageExternalStorage.request();
        isGranted = status.isGranted;
      } else {
        final status = await Permission.storage.request();
        isGranted = status.isGranted;
      }
    } else {
      isGranted = true;
    }

    if (isGranted) {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final pickedFile = result.files.single;
        field.didChange(pickedFile.path);
        field.validate();
      }
    } else {
      if (mounted) {
        _showPermissionDialog(l10n.resumePermissionRequired);
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _primaryColor,
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _SubmissionOverlay extends StatefulWidget {
  final bool isOnline;
  const _SubmissionOverlay({required this.isOnline});

  @override
  State<_SubmissionOverlay> createState() => _SubmissionOverlayState();
}

class _SubmissionOverlayState extends State<_SubmissionOverlay> with TickerProviderStateMixin {
  late final AnimationController _cloudController;
  late final AnimationController _saveController;
  late final Animation<double> _saveAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isOnline) {
      _cloudController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      )..repeat(reverse: true);
    } else {
      _saveController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _saveAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _saveController, curve: Curves.easeInOut),
      );
      _saveController.forward().then((_) => _saveController.reverse());
    }
  }

  @override
  void dispose() {
    if (widget.isOnline) {
      _cloudController.dispose();
    } else {
      _saveController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isOnline)
                AnimatedBuilder(
                  animation: _cloudController,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, -5 * _cloudController.value),
                    child: child,
                  ),
                  child: const Icon(Icons.cloud_upload, color: Color(0xFF673AB7), size: 48),
                )
              else
                ScaleTransition(
                  scale: _saveAnimation,
                  child: const Icon(Icons.save, color: Colors.orange, size: 48),
                ),
              const SizedBox(height: 16),
              Text(
                widget.isOnline ? 'Submitting and syncing...' : 'Saved offline. Will sync later.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
