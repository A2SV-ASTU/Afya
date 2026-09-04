import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../app/router/route_paths.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileBloc>()..add(LoadProfile()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xFFF2FAF5);
  static const Color primaryGreen = Color(0xFF136043);
  static const Color highlightGreen = Color(0xFF7CF0AD);
  static const Color textDark = Color(0xFF17211B);
  static const Color textMuted = Color(0xFF68736D);
  static const Color borderColor = Color(0xFFDCE8E0);
  static const Color errorRed = Color(0xFFD9534F);

  // ============================================================
  // FORM
  // ============================================================

  final _demographicsKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController =
      TextEditingController();

  final TextEditingController _lastNameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _phoneController =
      TextEditingController();

  final TextEditingController _dobController =
      TextEditingController();

  final TextEditingController _emergencyContactNameController =
      TextEditingController();

  final TextEditingController _emergencyContactPhoneController =
      TextEditingController();

  DateTime? _selectedDate;

  String _genderValue = '';

  String _bloodTypeValue = '';

  bool _isEditing = false;

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  File? _profileImage;

  final ImagePicker _imagePicker = ImagePicker();

  String? _currentUserId;

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  bool _appointmentReminders = true;
  bool _testResults = true;
  bool _healthTips = false;

  // ============================================================
  // INIT / DISPOSE
  // ============================================================

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();

    super.dispose();
  }

  // ============================================================
  // PROFILE DATA
  // ============================================================

  void _syncControllers(dynamic profile) {
    _currentUserId = profile.id;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';

    _genderValue = profile.gender ?? '';

    _selectedDate = profile.dateOfBirth;

    _dobController.text = profile.dateOfBirth == null
        ? ''
        : DateFormat(
            'MMM dd, yyyy',
          ).format(profile.dateOfBirth!);

    // Blood type
    _bloodTypeValue = profile.bloodType ?? '';

    // Emergency contact
    _emergencyContactNameController.text =
        profile.emergencyContactName ?? '';

    _emergencyContactPhoneController.text =
        profile.emergencyContactPhone ?? '';

    _loadSavedProfileImage();

    _loadNotificationSettings();
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime(
            now.year - 20,
            now.month,
            now.day,
          ),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = picked;

      _dobController.text = DateFormat(
        'MMM dd, yyyy',
      ).format(picked);
    });
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  void _saveProfile() {
    if (!_demographicsKey.currentState!.validate()) {
      return;
    }

    context.read<ProfileBloc>().add(
          UpdateProfileRequested(
            firstName:
                _firstNameController.text.trim(),

            lastName:
                _lastNameController.text.trim(),

            phone:
                _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),

            gender:
                _genderValue.isEmpty
                    ? null
                    : _genderValue,

            dateOfBirth:
                _selectedDate,

            bloodType:
                _bloodTypeValue.isEmpty
                    ? null
                    : _bloodTypeValue,

            emergencyContactName:
                _emergencyContactNameController
                        .text
                        .trim()
                        .isEmpty
                    ? null
                    : _emergencyContactNameController
                        .text
                        .trim(),
            email: _emailController.text.trim(),
            emergencyContactPhone:
                _emergencyContactPhoneController
                        .text
                        .trim()
                        .isEmpty
                    ? null
                    : _emergencyContactPhoneController
                        .text
                        .trim(),
          ),
        );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  
Future<void> _pickProfileImage() async {
  try {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedImage == null) {
      return;
    }

    final directory = await getApplicationDocumentsDirectory();

    final imageDirectory = Directory(
      '${directory.path}/profile_images',
    );

    if (!await imageDirectory.exists()) {
      await imageDirectory.create(
        recursive: true,
      );
    }

    final userId = _currentUserId ?? 'current_user';

    // Create a unique filename for every new profile picture.
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final savedImage = File(
      '${imageDirectory.path}/profile_${userId}_$timestamp.jpg',
    );

    // Copy the newly selected image to the new path.
    await File(pickedImage.path).copy(
      savedImage.path,
    );

    // Save the NEW path in Hive.
    final box = await Hive.openBox('profileBox');

    await box.put(
      'profileImage_$userId',
      savedImage.path,
    );

    if (!mounted) {
      return;
    }

    // Immediately show the newly selected image.
    setState(() {
      _profileImage = savedImage;
    });

    _showMessage(
      'Profile picture updated.',
    );
  } catch (e) {
    _showMessage(
      'Unable to select profile picture.',
      error: true,
    );
  }
}


  Future<void> _loadSavedProfileImage() async {
    if (_currentUserId == null) {
      return;
    }

    try {
      final box = await Hive.openBox(
        'profileBox',
      );

      final savedPath = box.get(
        'profileImage_$_currentUserId',
      );

      if (savedPath == null) {
        return;
      }

      final file = File(
        savedPath.toString(),
      );

      if (!await file.exists()) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _profileImage = file;
      });
    } catch (_) {
      // Ignore local image loading errors.
    }
  }

  // ============================================================
  // NOTIFICATION SETTINGS
  // ============================================================

  Future<void> _loadNotificationSettings() async {
    if (_currentUserId == null) {
      return;
    }

    try {
      final box = await Hive.openBox(
        'profileBox',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _appointmentReminders =
            box.get(
              'appointmentReminders_$_currentUserId',
              defaultValue: true,
            ) as bool;

        _testResults =
            box.get(
              'testResults_$_currentUserId',
              defaultValue: true,
            ) as bool;

        _healthTips =
            box.get(
              'healthTips_$_currentUserId',
              defaultValue: false,
            ) as bool;
      });
    } catch (_) {
      // Keep defaults.
    }
  }

  Future<void> _saveNotificationSetting(
    String key,
    bool value,
  ) async {
    if (_currentUserId == null) {
      return;
    }

    try {
      final box = await Hive.openBox(
        'profileBox',
      );

      await box.put(
        '${key}_$_currentUserId',
        value,
      );
    } catch (_) {
      // Ignore local storage errors.
    }
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _showChangePasswordDialog() async {
    final formKey =
        GlobalKey<FormState>();

    final oldPasswordController =
        TextEditingController();

    final newPasswordController =
        TextEditingController();

    final confirmPasswordController =
        TextEditingController();

    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                'Change Password',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              content:
                  SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller:
                            oldPasswordController,
                        obscureText:
                            obscureOld,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Current Password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(
                                () {
                                  obscureOld =
                                      !obscureOld;
                                },
                              );
                            },
                            icon: Icon(
                              obscureOld
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .isEmpty) {
                            return 'Enter current password';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextFormField(
                        controller:
                            newPasswordController,
                        obscureText:
                            obscureNew,
                        decoration:
                            InputDecoration(
                          labelText:
                              'New Password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(
                                () {
                                  obscureNew =
                                      !obscureNew;
                                },
                              );
                            },
                            icon: Icon(
                              obscureNew
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value.length <
                                  8) {
                            return 'Minimum 8 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      TextFormField(
                        controller:
                            confirmPasswordController,
                        obscureText:
                            obscureConfirm,
                        decoration:
                            InputDecoration(
                          labelText:
                              'Confirm New Password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon:
                              IconButton(
                            onPressed: () {
                              setDialogState(
                                () {
                                  obscureConfirm =
                                      !obscureConfirm;
                                },
                              );
                            },
                            icon: Icon(
                              obscureConfirm
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator:
                            (value) {
                          if (value !=
                              newPasswordController
                                  .text) {
                            return 'Passwords do not match';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: textMuted,
                    ),
                  ),
                ),

                BlocBuilder<
                    ProfileBloc,
                    ProfileState>(
                  builder: (
                    context,
                    state,
                  ) {
                    final loading =
                        state
                            is ProfileActionLoading;

                    return ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryGreen,
                        foregroundColor:
                            Colors.white,
                      ),

                      onPressed:
                          loading
                              ? null
                              : () {
                                  if (!formKey
                                      .currentState!
                                      .validate()) {
                                    return;
                                  }

                                  context
                                      .read<
                                          ProfileBloc>()
                                      .add(
                                        ChangePasswordRequested(
                                          oldPassword:
                                              oldPasswordController
                                                  .text,
                                          newPassword:
                                              newPasswordController
                                                  .text,
                                        ),
                                      );
                                },

                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.white,
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Text(
                              'Update',
                            ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _handleLogout() async {
    final confirmed =
        await _showConfirmationDialog(
      title: 'Sign Out',
      content:
          'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (confirmed == true &&
        mounted) {
      context.read<ProfileBloc>().add(
            LogoutRequested(),
          );
    }
  }

  // ============================================================
  // DEACTIVATE ACCOUNT
  // ============================================================

  Future<void> _handleDeactivate() async {
    final confirmed =
        await _showConfirmationDialog(
      title: 'Deactivate Account',
      content:
          'Are you sure you want to deactivate your account? This action cannot be undone.',
      confirmText: 'Deactivate',
      destructive: true,
    );

    if (confirmed == true &&
        mounted) {
      context.read<ProfileBloc>().add(
            DeactivateRequested(),
          );
    }
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          content: Text(content),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: textMuted,
                ),
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    destructive
                        ? errorRed
                        : primaryGreen,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: Text(
                confirmText,
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // STATE HANDLER
  // ============================================================

  void _handleState(
    ProfileState state,
  ) {
    if (state is ProfileLoaded) {
      _syncControllers(
        state.profile,
      );
      return;
    }

    if (state is ProfileUpdated) {
      _syncControllers(
        state.profile,
      );

      setState(() {
        _isEditing = false;
      });

      _showMessage(
        'Profile updated successfully.',
      );

      return;
    }

    if (state is PasswordChanged) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop();

      _showMessage(
        'Password changed successfully.',
      );

      return;
    }

    if (state is ProfileLoggedOut) {
      _showMessage(
        'Signed out successfully.',
      );

      context.go(
        RoutePaths.signIn,
      );

      return;
    }

    if (state is ProfileDeactivated) {
      _showMessage(
        'Account deactivated.',
      );

      context.go(
        RoutePaths.signIn,
      );

      return;
    }

    if (state is ProfileError) {
      _showMessage(
        _cleanErrorMessage(
          state.message,
        ),
        error: true,
      );
    }
  }

  String _cleanErrorMessage(
    String message,
  ) {
    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              error
                  ? errorRed
                  : primaryGreen,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return BlocListener<
        ProfileBloc,
        ProfileState>(
      listener: (
        _,
        state,
      ) {
        _handleState(state);
      },

      child: Scaffold(
        backgroundColor:
            backgroundColor,

        appBar: AppBar(
          backgroundColor:
              backgroundColor,
          elevation: 0,

          

          title: const Text(
            'Afya',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 26,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          centerTitle: true,

          actions: [
            Padding(
              padding:
                  const EdgeInsets.only(
                right: 16,
              ),

              child: GestureDetector(
                onTap:
                    _pickProfileImage,

                child: CircleAvatar(
                  radius: 18,
                  backgroundColor:
                      highlightGreen,

                  backgroundImage:
                      _profileImage !=
                              null
                          ? FileImage(
                              _profileImage!,
                            )
                          : null,

                  child:
                      _profileImage ==
                              null
                          ? const Icon(
                              Icons.person,
                              color:
                                  primaryGreen,
                              size: 20,
                            )
                          : null,
                ),
              ),
            ),
          ],
        ),

        body: BlocBuilder<
            ProfileBloc,
            ProfileState>(
          builder: (
            context,
            state,
          ) {
            if (state
                    is ProfileInitial ||
                state
                    is ProfileLoading) {
              return const Center(
                child:
                    CircularProgressIndicator(
                  color: primaryGreen,
                ),
              );
            }

            if (state is ProfileError) {
              return _buildErrorState(
                state.message,
              );
            }

            return _buildProfileBody(
              isActionLoading:
                  state
                      is ProfileActionLoading,
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
    String message,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: errorRed,
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _cleanErrorMessage(
                message,
              ),
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: textMuted,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<
                        ProfileBloc>()
                    .add(
                      LoadProfile(),
                    );
              },

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryGreen,
                foregroundColor:
                    Colors.white,
              ),

              icon: const Icon(
                Icons.refresh,
              ),

              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE BODY
  // ============================================================

  Widget _buildProfileBody({
    bool isActionLoading = false,
  }) {
    return SingleChildScrollView(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),

      child: Column(
        children: [
          _buildProfileHeader(),

          const SizedBox(
            height: 24,
          ),

          _buildPersonalInformationCard(),

          const SizedBox(
            height: 20,
          ),

          _buildChangePasswordButton(
            disabled:
                isActionLoading,
          ),

          const SizedBox(
            height: 20,
          ),

          _buildNotificationsCard(),

          const SizedBox(
            height: 24,
          ),

          _buildSignOutButton(
            disabled:
                isActionLoading,
          ),

          const SizedBox(
            height: 12,
          ),

          _buildDeleteButton(
            disabled:
                isActionLoading,
          ),

          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final fullName =
        '${_firstNameController.text} '
        '${_lastNameController.text}'
            .trim();

    return Column(
      children: [
        GestureDetector(
          onTap:
              _pickProfileImage,

          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,

                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,

                  color:
                      highlightGreen,

                  border:
                      Border.all(
                    color:
                        Colors.white,
                    width: 4,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:
                        .05,
                      ),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],

                  image:
                      _profileImage !=
                              null
                          ? DecorationImage(
                              image:
                                  FileImage(
                                _profileImage!,
                              ),
                              fit:
                                  BoxFit.cover,
                            )
                          : null,
                ),

                child:
                    _profileImage ==
                            null
                        ? Center(
                            child: Text(
                              _getInitials(
                                fullName,
                              ),

                              style:
                                  const TextStyle(
                                color:
                                    primaryGreen,
                                fontSize:
                                    38,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
              ),

              Positioned(
                bottom: 2,
                right: 2,

                child: Container(
                  padding:
                      const EdgeInsets.all(
                    7,
                  ),

                  decoration:
                      const BoxDecoration(
                    color:
                        primaryGreen,
                    shape:
                        BoxShape.circle,
                  ),

                  child:
                      const Icon(
                    Icons.camera_alt_outlined,
                    color:
                        Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        Text(
          fullName.isEmpty
              ? 'My Profile'
              : fullName,

          style:
              const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.w500,
            color: textDark,
          ),
        ),
      ],
    );
  }

  String _getInitials(
    String name,
  ) {
    if (name.trim().isEmpty) {
      return '?';
    }

    final parts =
        name.trim().split(
              RegExp(r'\s+'),
            );

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts.first[0]}'
            '${parts.last[0]}'
        .toUpperCase();
  }

  // ============================================================
  // PERSONAL INFORMATION CARD
  // ============================================================

  Widget _buildPersonalInformationCard() {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:.02),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Form(
        key: _demographicsKey,

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                const Text(
                  'Personal Information',

                  style:
                      TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                    color: textDark,
                  ),
                ),

                IconButton(
                  constraints:
                      const BoxConstraints(),

                  padding:
                      EdgeInsets.zero,

                  icon: Icon(
                    _isEditing
                        ? Icons.close
                        : Icons.edit_outlined,
                    color:
                        primaryGreen,
                    size: 20,
                  ),

                  onPressed: () {
                    setState(() {
                      _isEditing =
                          !_isEditing;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            if (_isEditing)
              _buildEditForm()
            else
              _buildReadOnlyInformation(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EDIT FORM
  // ============================================================

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'First Name',
          controller:
              _firstNameController,
        ),

        const SizedBox(
          height: 15,
        ),

        _buildTextField(
          label: 'Last Name',
          controller:
              _lastNameController,
        ),

        const SizedBox(
          height: 15,
        ),

        _buildTextField(
          label: 'Email Address',
          controller:
              _emailController,
          keyboardType:
              TextInputType.emailAddress,
          enabled: false,
          requiredField: false,
        ),

        const SizedBox(
          height: 15,
        ),

        _buildTextField(
          label: 'Phone Number',
          controller:
              _phoneController,
          keyboardType:
              TextInputType.phone,
          requiredField: false,
        ),

        const SizedBox(
          height: 15,
        ),

        TextField(
          controller:
              _dobController,

          readOnly: true,

          onTap:
              _selectDate,

          decoration:
              InputDecoration(
            labelText:
                'Date of Birth',

            suffixIcon:
                const Icon(
              Icons
                  .calendar_today_outlined,
              color:
                  primaryGreen,
            ),

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(
                color:
                    borderColor,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(
                color:
                    primaryGreen,
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 15,
        ),

        // ======================================================
        // BIOLOGICAL SEX
        // ======================================================

        DropdownButtonFormField<
            String>(
          initialValue:
              _validGenderValue(),

          decoration:
              InputDecoration(
            labelText:
                'Biological Sex',

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(
                color:
                    borderColor,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(
                color:
                    primaryGreen,
                width: 1.5,
              ),
            ),
          ),

          items: const [
            DropdownMenuItem(
              value: 'Male',
              child:
                  Text('Male'),
            ),
            DropdownMenuItem(
              value: 'Female',
              child:
                  Text('Female'),
            ),
            DropdownMenuItem(
              value: 'Other',
              child:
                  Text('Other'),
            ),
          ],

          onChanged:
              (value) {
            setState(() {
              _genderValue =
                  value ?? '';
            });
          },
        ),

        const SizedBox(
          height: 15,
        ),

        // ======================================================
        // BLOOD TYPE
        // ======================================================

        DropdownButtonFormField<
            String>(
          initialValue:
              _validBloodTypeValue(),

          decoration:
              InputDecoration(
            labelText:
                'Blood Type',

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(
                color:
                    borderColor,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),

              borderSide:
                  const BorderSide(
                color:
                    primaryGreen,
                width: 1.5,
              ),
            ),
          ),

          items: const [
            DropdownMenuItem(
              value: 'A+',
              child: Text('A+'),
            ),
            DropdownMenuItem(
              value: 'A-',
              child: Text('A-'),
            ),
            DropdownMenuItem(
              value: 'B+',
              child: Text('B+'),
            ),
            DropdownMenuItem(
              value: 'B-',
              child: Text('B-'),
            ),
            DropdownMenuItem(
              value: 'AB+',
              child: Text('AB+'),
            ),
            DropdownMenuItem(
              value: 'AB-',
              child: Text('AB-'),
            ),
            DropdownMenuItem(
              value: 'O+',
              child: Text('O+'),
            ),
            DropdownMenuItem(
              value: 'O-',
              child: Text('O-'),
            ),
          ],

          onChanged:
              (value) {
            setState(() {
              _bloodTypeValue =
                  value ?? '';
            });
          },
        ),

        const SizedBox(
          height: 22,
        ),

        // ======================================================
        // EMERGENCY CONTACT
        // ======================================================

        const Align(
  alignment: Alignment.centerLeft,
  child: Text(
    'Emergency Contact',
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: textDark,
    ),
  ),
),

        const SizedBox(
          height: 12,
        ),

        _buildTextField(
          label:
              'Emergency Contact Name',
          controller:
              _emergencyContactNameController,
          requiredField: false,
        ),

        const SizedBox(
          height: 15,
        ),

        _buildTextField(
          label:
              'Emergency Contact Phone',
          controller:
              _emergencyContactPhoneController,
          keyboardType:
              TextInputType.phone,
          requiredField: false,
        ),

        const SizedBox(
          height: 20,
        ),

        // ======================================================
        // SAVE
        // ======================================================

        BlocBuilder<
            ProfileBloc,
            ProfileState>(
          builder: (
            context,
            state,
          ) {
            final loading =
                state
                    is ProfileActionLoading;

            return SizedBox(
              width:
                  double.infinity,
              height: 50,

              child:
                  ElevatedButton(
                onPressed:
                    loading
                        ? null
                        : _saveProfile,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryGreen,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          color:
                              Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Demographics',
                        style:
                            TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // VALID GENDER
  // ============================================================

  String? _validGenderValue() {
    const values = [
      'Male',
      'Female',
      'Other',
    ];

    if (values.contains(
      _genderValue,
    )) {
      return _genderValue;
    }

    return null;
  }

  // ============================================================
  // VALID BLOOD TYPE
  // ============================================================

  String? _validBloodTypeValue() {
    const values = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-',
    ];

    if (values.contains(
      _bloodTypeValue,
    )) {
      return _bloodTypeValue;
    }

    return null;
  }

  // ============================================================
  // READ ONLY PROFILE
  // ============================================================

  Widget _buildReadOnlyInformation() {
    return Column(
      children: [
        _buildInfoRow(
          'Email Address',
          _emailController.text.isEmpty
              ? 'Not provided'
              : _emailController.text,
        ),

        _buildDivider(),

        _buildInfoRow(
          'Phone Number',
          _phoneController.text.isEmpty
              ? 'Not provided'
              : _phoneController.text,
        ),

        _buildDivider(),

        _buildInfoRow(
          'Date of Birth',
          _dobController.text.isEmpty
              ? 'Not provided'
              : _dobController.text,
        ),

        _buildDivider(),

        _buildInfoRow(
          'Biological Sex',
          _genderValue.isEmpty
              ? 'Not provided'
              : _genderValue,
        ),

        _buildDivider(),

        _buildInfoRow(
          'Blood Type',
          _bloodTypeValue.isEmpty
              ? 'Not provided'
              : _bloodTypeValue,
        ),

        _buildDivider(),

        _buildInfoRow(
          'Emergency Contact',
          _emergencyContactNameController
                  .text
                  .isEmpty
              ? 'Not provided'
              : _emergencyContactNameController
                  .text,
        ),

        if (_emergencyContactPhoneController
            .text
            .isNotEmpty) ...[
          const SizedBox(
            height: 8,
          ),

          _buildInfoRow(
            'Emergency Phone',
            _emergencyContactPhoneController
                .text,
          ),
        ],
      ],
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required String label,
    required TextEditingController
        controller,
    TextInputType? keyboardType,
    bool enabled = true,
    bool requiredField = true,
  }) {
    return TextFormField(
      controller: controller,

      enabled: enabled,

      keyboardType:
          keyboardType,

      decoration:
          InputDecoration(
        labelText: label,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              const BorderSide(
            color: borderColor,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),

          borderSide:
              const BorderSide(
            color:
                primaryGreen,
            width: 1.5,
          ),
        ),
      ),

      validator:
          (value) {
        if (!requiredField) {
          return null;
        }

        if (value ==
                null ||
            value.trim().isEmpty) {
          return '$label cannot be empty';
        }

        return null;
      },
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style:
                    const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                value,

                style:
                    const TextStyle(
                  fontSize: 15,
                  color: textDark,
                  fontWeight:
                      FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 12,
      ),

      child: Divider(
        color: borderColor,
        height: 1,
      ),
    );
  }

  // ============================================================
  // CHANGE PASSWORD BUTTON
  // ============================================================

  Widget _buildChangePasswordButton({
    required bool disabled,
  }) {
    return OutlinedButton.icon(
      onPressed:
          disabled
              ? null
              : _showChangePasswordDialog,

      style:
          OutlinedButton.styleFrom(
        minimumSize:
            const Size(
          double.infinity,
          48,
        ),

        side:
            const BorderSide(
          color:
              primaryGreen,
          width: 1.5,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),

      icon: const Icon(
        Icons.lock_outline,
        color: primaryGreen,
      ),

      label: const Text(
        'Change Password',
        style: TextStyle(
          color:
              primaryGreen,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Widget _buildNotificationsCard() {
    return Container(
      padding:
          const EdgeInsets.all(20),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:.02),
            blurRadius: 10,
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [
          const Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,

            children: [
              Text(
                'Notifications',

                style:
                    TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                  color: textDark,
                ),
              ),

              Icon(
                Icons
                    .notifications_none,
                color: textMuted,
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          _buildNotificationItem(
            title:
                'Appointment Reminders',
            subtitle:
                'SMS and Email alerts',
            value:
                _appointmentReminders,

            onChanged:
                (value) {
              setState(() {
                _appointmentReminders =
                    value;
              });

              _saveNotificationSetting(
                'appointmentReminders',
                value,
              );
            },
          ),

          _buildDivider(),

          _buildNotificationItem(
            title:
                'Test Results',
            subtitle:
                'Secure message notifications',
            value:
                _testResults,

            onChanged:
                (value) {
              setState(() {
                _testResults =
                    value;
              });

              _saveNotificationSetting(
                'testResults',
                value,
              );
            },
          ),

          _buildDivider(),

          _buildNotificationItem(
            title:
                'Health Tips & News',
            subtitle:
                'Weekly newsletter',
            value:
                _healthTips,

            onChanged:
                (value) {
              setState(() {
                _healthTips =
                    value;
              });

              _saveNotificationSetting(
                'healthTips',
                value,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>
        onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Text(
                title,

                style:
                    const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w500,
                  color: textDark,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              Text(
                subtitle,

                style:
                    const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          onChanged:
              onChanged,
          activeThumbColor:
              Colors.white,
          activeTrackColor:
              primaryGreen,
        ),
      ],
    );
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Widget _buildSignOutButton({
    required bool disabled,
  }) {
    return OutlinedButton(
      onPressed:
          disabled
              ? null
              : _handleLogout,

      style:
          OutlinedButton.styleFrom(
        minimumSize:
            const Size(
          double.infinity,
          48,
        ),

        side:
            const BorderSide(
          color: errorRed,
          width: 1.5,
        ),

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
            12,
          ),
        ),
      ),

      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment
                .center,

        children: [
          Icon(
            Icons.logout,
            color: errorRed,
          ),

          SizedBox(
            width: 8,
          ),

          Text(
            'Sign Out',

            style:
                TextStyle(
              color:
                  errorRed,
              fontWeight:
                  FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE ACCOUNT
  // ============================================================

  Widget _buildDeleteButton({
    required bool disabled,
  }) {
    return TextButton.icon(
      onPressed:
          disabled
              ? null
              : _handleDeactivate,

      icon: const Icon(
        Icons
            .disabled_by_default_outlined,
        color: errorRed,
        size: 18,
      ),

      label: const Text(
        'Delete Account',

        style:
            TextStyle(
          color: errorRed,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }
}