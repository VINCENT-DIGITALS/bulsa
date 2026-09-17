import 'package:bulsa/game/data/local_game_store.dart';
import 'package:bulsa/game/models/game_models.dart';
import 'package:bulsa/theme/bulsa_theme.dart';
import 'package:bulsa/widgets/bulsa_button.dart';
import 'package:bulsa/widgets/bulsa_page.dart';
import 'package:flutter/material.dart';

const _workTags = ['Remote work', 'Commuter', 'Supports family'];

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.store});

  final LocalGameStore store;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _companyNameController = TextEditingController();
  late Future<PlayerProfile> _profileFuture;
  EmploymentType _employmentType = EmploymentType.salaried;
  ProfileAvatar _avatar = ProfileAvatar.circle;
  Set<String> _tags = {};

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<PlayerProfile> _loadProfile() async {
    final profile = await widget.store.loadProfile();
    _applyProfile(profile);
    return profile;
  }

  void _applyProfile(PlayerProfile profile) {
    _displayNameController.text = profile.displayName;
    _jobTitleController.text = profile.jobTitle;
    _jobDescriptionController.text = profile.jobDescription;
    _companyNameController.text = profile.companyName;
    _employmentType = profile.employmentType;
    _avatar = profile.avatar;
    _tags = {...profile.workTags};
  }

  Future<void> _save() async {
    final profile = PlayerProfile(
      displayName: _displayNameController.text,
      jobTitle: _jobTitleController.text,
      jobDescription: _jobDescriptionController.text,
      companyName: _companyNameController.text,
      employmentType: _employmentType,
      workTags: _tags,
      avatar: _avatar,
    );
    await widget.store.saveProfile(profile);
    if (!mounted) return;
    setState(() => _profileFuture = Future.value(profile));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved on this device.')),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _jobTitleController.dispose();
    _jobDescriptionController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return BulsaPage(
          title: 'Profile',
          description:
              'Optional local details make fictional events feel more relevant.',
          icon: Icons.person_outline,
          children: [
            BulsaInfoCard(
              icon: _avatarIcon(_avatar),
              title: 'Optional and local only',
              message:
                  'Use a nickname and work context to make game events feel more relevant. Do not enter private employment or banking information.',
            ),
            const SizedBox(height: BulsaSpacing.xLarge),
            Text('AVATAR', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: BulsaSpacing.small),
            SegmentedButton<ProfileAvatar>(
              segments: ProfileAvatar.values
                  .map(
                    (avatar) => ButtonSegment(
                      value: avatar,
                      icon: Icon(_avatarIcon(avatar)),
                      label: Text(_avatarLabel(avatar)),
                    ),
                  )
                  .toList(),
              selected: {_avatar},
              onSelectionChanged: (selection) =>
                  setState(() => _avatar = selection.single),
            ),
            const SizedBox(height: BulsaSpacing.xLarge),
            _Field(
              controller: _displayNameController,
              label: 'Display name',
              hint: 'e.g. Vin',
            ),
            const SizedBox(height: BulsaSpacing.medium),
            _Field(
              controller: _jobTitleController,
              label: 'Job title',
              hint: 'e.g. Mobile app developer',
            ),
            const SizedBox(height: BulsaSpacing.medium),
            _Field(
              controller: _jobDescriptionController,
              label: 'Work description',
              hint: 'Optional short description of your work',
              maxLines: 3,
            ),
            const SizedBox(height: BulsaSpacing.medium),
            _Field(
              controller: _companyNameController,
              label: 'Company nickname',
              hint: 'Optional; avoid sensitive employer details',
            ),
            const SizedBox(height: BulsaSpacing.xLarge),
            Text(
              'EMPLOYMENT TYPE',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: BulsaSpacing.small),
            DropdownButtonFormField<EmploymentType>(
              initialValue: _employmentType,
              decoration: const InputDecoration(),
              items: EmploymentType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_employmentLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (type) =>
                  setState(() => _employmentType = type ?? _employmentType),
            ),
            const SizedBox(height: BulsaSpacing.xLarge),
            Text('WORK TAGS', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: BulsaSpacing.xSmall),
            Text(
              'These only influence which fictional event cards are more likely.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: BulsaSpacing.small),
            Wrap(
              spacing: BulsaSpacing.small,
              runSpacing: BulsaSpacing.small,
              children: _workTags
                  .map(
                    (tag) => FilterChip(
                      label: Text(tag),
                      selected: _tags.contains(tag),
                      onSelected: (selected) => setState(() {
                        _tags = {..._tags};
                        selected ? _tags.add(tag) : _tags.remove(tag);
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: BulsaSpacing.xLarge),
            BulsaPrimaryButton(label: 'Save profile', onPressed: _save),
            const SizedBox(height: BulsaSpacing.medium),
            Text(
              'Paydays and confirmed income are configured in Calendar. Project incentives and bonuses stay possible income until a game event awards them.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
}

IconData _avatarIcon(ProfileAvatar avatar) => switch (avatar) {
  ProfileAvatar.circle => Icons.circle_outlined,
  ProfileAvatar.square => Icons.square_outlined,
  ProfileAvatar.triangle => Icons.change_history_outlined,
};

String _avatarLabel(ProfileAvatar avatar) => switch (avatar) {
  ProfileAvatar.circle => 'Circle',
  ProfileAvatar.square => 'Square',
  ProfileAvatar.triangle => 'Triangle',
};

String _employmentLabel(EmploymentType type) => switch (type) {
  EmploymentType.salaried => 'Salaried',
  EmploymentType.contractual => 'Contractual',
  EmploymentType.freelance => 'Freelance',
  EmploymentType.businessOwner => 'Business owner',
  EmploymentType.student => 'Student',
};
