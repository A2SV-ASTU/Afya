import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

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
  static const Color backgroundColor = Color(0xFFF2FAF5);
  static const Color primaryGreen = Color(0xFF136043);
  static const Color highlightGreen = Color(0xFF7CF0AD);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color errorRed = Color(0xFFC82D2D);

  final _demographicsKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isEditing = false;

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  bool _appointmentReminders = true;
  bool _testResults = true;
  bool _healthTips = false;

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

    super.dispose();
  }

  void _populateFields(ProfileLoaded state) {
    final profile = state.profile;

    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone ?? '';

    _selectedGender = profile.gender;
    _selectedDateOfBirth = profile.dateOfBirth;

    _dobController.text = profile.dateOfBirth == null
        ? ''
        : DateFormat(
            'MMM dd, yyyy',
          ).format(profile.dateOfBirth!);
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDateOfBirth ??
          DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat(
          'MMM dd, yyyy',
        ).format(picked);
      });
    }
  }

  void _saveDemographics() {
    if (!_demographicsKey.currentState!.validate()) {
      return;
    }

    context.read<ProfileBloc>().add(
      UpdateProfileRequested(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth,
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final formKey = GlobalKey<FormState>();

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
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Change Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller:
                            oldPasswordController,
                        obscureText: obscureOld,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureOld =
                                    !obscureOld;
                              });
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
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Enter current password';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller:
                            newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureNew =
                                    !obscureNew;
                              });
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
                        validator: (value) {
                          if (value == null ||
                              value.length < 6) {
                            return 'Minimum 6 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller:
                            confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText:
                              'Confirm New Password',
                          border:
                              const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm =
                                    !obscureConfirm;
                              });
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
                        validator: (value) {
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
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: textMuted,
                    ),
                  ),
                ),
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    final loading =
                        state is ProfileActionLoading;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: loading
                          ? null
                          : () {
                              if (!formKey
                                  .currentState!
                                  .validate()) {
                                return;
                              }

                              context
                                  .read<ProfileBloc>()
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
                                color: Colors.white,
                                strokeWidth: 2,
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

  Future<void> _handleLogout() async {
    final confirmed =
        await _showConfirmationDialog(
      title: 'Sign Out',
      content:
          'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
    );

    if (confirmed == true && mounted) {
      context.read<ProfileBloc>().add(
        LogoutRequested(),
      );
    }
  }

  Future<void> _handleDeactivate() async {
    final confirmed =
        await _showConfirmationDialog(
      title: 'Deactivate Account',
      content:
          'Are you sure you want to deactivate your account? This action cannot be undone.',
      confirmText: 'Deactivate',
      destructive: true,
    );

    if (confirmed == true && mounted) {
      context.read<ProfileBloc>().add(
        DeactivateRequested(),
      );
    }
  }

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
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: textMuted,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: destructive
                    ? errorRed
                    : primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              error ? errorRed : primaryGreen,
        ),
      );
  }

  void _handleState(ProfileState state) {
    if (state is ProfileLoaded) {
      _populateFields(state);
      return;
    }

    if (state is ProfileUpdated) {
      _populateFields(
        ProfileLoaded(state.profile),
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

      return;
    }

    if (state is ProfileDeactivated) {
      _showMessage(
        'Account deactivated.',
      );

      return;
    }

    if (state is ProfileError) {
      _showMessage(
        _cleanErrorMessage(state.message),
        error: true,
      );
    }
  }

  String _cleanErrorMessage(String message) {
    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (_, state) {
        _handleState(state);
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: primaryGreen,
              size: 26,
            ),
            onPressed: () {},
          ),
          title: const Text(
            'Afya',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: primaryGreen,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileInitial ||
                state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
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
                  state is ProfileActionLoading,
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: errorRed,
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _cleanErrorMessage(message),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textMuted,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileBloc>().add(
                  LoadProfile(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBody({
    bool isActionLoading = false,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Column(
        children: [
          _buildProfileHeader(),

          const SizedBox(height: 24),

          _buildPersonalInformationCard(),

          const SizedBox(height: 20),

          _buildChangePasswordButton(
            disabled: isActionLoading,
          ),

          const SizedBox(height: 20),

          _buildNotificationsCard(),

          const SizedBox(height: 24),

          _buildSignOutButton(
            disabled: isActionLoading,
          ),

          const SizedBox(height: 12),

          _buildDeleteButton(
            disabled: isActionLoading,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final fullName =
        '${_firstNameController.text} ${_lastNameController.text}'
            .trim();

    final initials = _getInitials(fullName);

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: highlightGreen,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: primaryGreen,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          fullName.isEmpty
              ? 'My Profile'
              : fullName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: textDark,
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) {
      return '?';
    }

    final parts =
        name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  Widget _buildPersonalInformationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _demographicsKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                IconButton(
                  constraints:
                      const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _isEditing
                        ? Icons.close
                        : Icons.edit_outlined,
                    color: primaryGreen,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_isEditing)
              _buildEditForm()
            else
              _buildReadOnlyInformation(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Column(
      children: [
        _buildEditableField(
          'First Name',
          _firstNameController,
        ),

        const SizedBox(height: 12),

        _buildEditableField(
          'Last Name',
          _lastNameController,
        ),

        const SizedBox(height: 12),

        _buildEditableField(
          'Email Address',
          _emailController,
          enabled: false,
        ),

        const SizedBox(height: 12),

        _buildEditableField(
          'Phone Number',
          _phoneController,
          requiredField: false,
        ),

        const SizedBox(height: 12),

        TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: _selectDateOfBirth,
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
            ),
          ),
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<String>(
          value: _validGenderValue(),
          decoration: const InputDecoration(
            labelText: 'Biological Sex',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Male',
              child: Text('Male'),
            ),
            DropdownMenuItem(
              value: 'Female',
              child: Text('Female'),
            ),
            DropdownMenuItem(
              value: 'Other',
              child: Text('Other'),
            ),
            DropdownMenuItem(
              value: 'Prefer not to say',
              child: Text(
                'Prefer not to say',
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
        ),

        const SizedBox(height: 16),

        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final loading =
                state is ProfileActionLoading;

            return ElevatedButton(
              onPressed:
                  loading ? null : _saveDemographics,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  double.infinity,
                  46,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Demographics',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }

  String? _validGenderValue() {
    const values = [
      'Male',
      'Female',
      'Other',
      'Prefer not to say',
    ];

    return values.contains(_selectedGender)
        ? _selectedGender
        : null;
  }

  Widget _buildReadOnlyInformation() {
    return Column(
      children: [
        _buildInfoItem(
          'Email Address',
          _emailController.text,
        ),

        _buildDivider(),

        _buildInfoItem(
          'Phone Number',
          _phoneController.text.isEmpty
              ? 'Not provided'
              : _phoneController.text,
        ),

        _buildDivider(),

        _buildInfoItem(
          'Date of Birth',
          _dobController.text.isEmpty
              ? 'Not provided'
              : _dobController.text,
        ),

        _buildDivider(),

        _buildInfoItem(
          'Biological Sex',
          _selectedGender ?? 'Not provided',
        ),
      ],
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
    bool requiredField = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (!requiredField) {
          return null;
        }

        if (value == null ||
            value.trim().isEmpty) {
          return '$label cannot be empty';
        }

        return null;
      },
    );
  }

  Widget _buildInfoItem(
    String label,
    String value, {
    Color valueColor = textDark,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: valueColor,
            fontWeight: isBold
                ? FontWeight.bold
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildChangePasswordButton({
    required bool disabled,
  }) {
    return OutlinedButton.icon(
      onPressed:
          disabled ? null : _showChangePasswordDialog,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          48,
        ),
        side: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(
        Icons.lock_outline,
        color: primaryGreen,
      ),
      label: const Text(
        'Change Password',
        style: TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              Icon(
                Icons.notifications_none,
                color: textMuted,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _buildSwitchItem(
            title: 'Appointment Reminders',
            subtitle: 'SMS and Email alerts',
            value: _appointmentReminders,
            onChanged: (value) {
              setState(() {
                _appointmentReminders = value;
              });
            },
          ),

          _buildDivider(),

          _buildSwitchItem(
            title: 'Test Results',
            subtitle:
                'Secure message notifications',
            value: _testResults,
            onChanged: (value) {
              setState(() {
                _testResults = value;
              });
            },
          ),

          _buildDivider(),

          _buildSwitchItem(
            title: 'Health Tips & News',
            subtitle: 'Weekly newsletter',
            value: _healthTips,
            onChanged: (value) {
              setState(() {
                _healthTips = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: primaryGreen,
        ),
      ],
    );
  }

  Widget _buildSignOutButton({
    required bool disabled,
  }) {
    return OutlinedButton(
      onPressed:
          disabled ? null : _handleLogout,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          48,
        ),
        side: const BorderSide(
          color: errorRed,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.logout,
            color: errorRed,
          ),
          SizedBox(width: 8),
          Text(
            'Sign Out',
            style: TextStyle(
              color: errorRed,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton({
    required bool disabled,
  }) {
    return TextButton.icon(
      onPressed:
          disabled ? null : _handleDeactivate,
      icon: const Icon(
        Icons.disabled_by_default_outlined,
        color: errorRed,
        size: 18,
      ),
      label: const Text(
        'Delete Account',
        style: TextStyle(
          color: errorRed,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Divider(
        color: borderLight,
        height: 1,
      ),
    );
  }
}
