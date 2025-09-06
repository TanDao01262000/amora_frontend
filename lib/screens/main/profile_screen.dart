import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/user.dart';
import '../theme_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  PartnerInfo? _cachedPartnerInfo;
  bool _isLoadingPartnerInfo = false;
  String? _partnerError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPartnerInfoIfExists();
    });
  }

  void _loadPartnerInfoIfExists() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user?.partnerId != null) {
      _loadPartnerInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.getThemeModeIcon()),
                onPressed: () => Navigator.pushNamed(context, '/theme-settings'),
              ),
            ],
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = authProvider.user;
              if (user == null) {
                return const Center(
                  child: Text('No user data available'),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50.0,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                user.username.isNotEmpty
                                    ? user.username[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              user.username,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              user.email ?? 'No email',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text(
                                'Member since ${_formatDate(user.createdAt ?? DateTime.now())}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Partner Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  'Partner Connection',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            if (user.partnerId != null) ...[
                              if (_isLoadingPartnerInfo)
                                const Center(child: CircularProgressIndicator())
                              else if (_cachedPartnerInfo != null) ...[
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      child: Text(
                                        _cachedPartnerInfo!.username.isNotEmpty
                                            ? _cachedPartnerInfo!.username[0].toUpperCase()
                                            : 'P',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 12.0),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _cachedPartnerInfo!.username,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Connected',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _showEditPartnerNameDialog(),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.refresh),
                                          onPressed: _loadPartnerInfo,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ] else if (_partnerError != null) ...[
                                Text(
                                  'Error loading partner: $_partnerError',
                                  style: TextStyle(color: Colors.red[600]),
                                ),
                                const SizedBox(height: 8.0),
                                ElevatedButton(
                                  onPressed: _loadPartnerInfo,
                                  child: const Text('Retry'),
                                ),
                              ] else ...[
                                const Text('Loading partner info...'),
                              ],
                            ] else ...[
                              const Text('No partner connected yet.'),
                              const SizedBox(height: 12.0),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showConnectPartnerDialog();
                                },
                                icon: const Icon(Icons.person_add),
                                label: const Text('Connect with Partner'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Settings Section
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.palette,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Theme Settings'),
                            subtitle: const Text('Customize app appearance'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ThemeSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1.0),
                          ListTile(
                            leading: Icon(
                              Icons.notifications,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Notifications'),
                            subtitle: const Text('Manage notification preferences'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Implement notifications settings
                            },
                          ),
                          const Divider(height: 1.0),
                          ListTile(
                            leading: Icon(
                              Icons.privacy_tip,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Privacy'),
                            subtitle: const Text('Privacy and security settings'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Implement privacy settings
                            },
                          ),
                          const Divider(height: 1.0),
                          ListTile(
                            leading: Icon(
                              Icons.help,
                              color: Theme.of(context).primaryColor,
                            ),
                            title: const Text('Help & Support'),
                            subtitle: const Text('Get help and contact support'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // TODO: Implement help and support
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            await authProvider.logout();
                            if (mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _loadPartnerInfo() {
    if (_isLoadingPartnerInfo) return;

    setState(() {
      _isLoadingPartnerInfo = true;
      _partnerError = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.getPartnerInfo().then((partnerInfo) {
      if (mounted) {
        setState(() {
          _cachedPartnerInfo = partnerInfo;
          _isLoadingPartnerInfo = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _partnerError = error.toString();
          _isLoadingPartnerInfo = false;
        });
      }
    });
  }

  void _showConnectPartnerDialog() {
    final usernameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect with Partner'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your partner\'s username to connect:'),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Partner Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              usernameController.dispose();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                final success = await authProvider.connectWithPartner(usernameController.text.trim());
                
                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully connected with partner!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _loadPartnerInfo();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(authProvider.error ?? 'Failed to connect with partner'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                
                usernameController.dispose();
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.year}';
  }

  void _showEditPartnerNameDialog() {
    final nameController = TextEditingController(text: _cachedPartnerInfo?.username ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Partner Name'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your partner\'s name:'),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Partner Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Partner name is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              nameController.dispose();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.updatePartnerName(nameController.text.trim());
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Partner name updated!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                
                nameController.dispose();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}