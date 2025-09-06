import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';

class TimelineScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProfile;
  
  const TimelineScreen({
    super.key,
    this.onNavigateToProfile,
  });

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTimelineIfPartnerExists();
    });
  }

  void _loadTimelineIfPartnerExists() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Only load timeline if user has a partner
    if (authProvider.user?.partnerId != null) {
      print('📝 TimelineScreen: Loading timeline for user with partner: ${authProvider.user?.partnerId}');
      Provider.of<TimelineProvider>(context, listen: false).loadTimeline();
    } else {
      print('📝 TimelineScreen: No partner connected, skipping timeline load');
    }
  }

  Future<void> _showCreateTimelineDialog() async {
    final noteController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
          title: const Text('Add Timeline Entry'),
        content: Form(
          key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(
                  labelText: 'Note',
                    border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Note is required';
                  }
                  if (value.trim().length > 500) {
                    return 'Note must be 500 characters or less';
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
              noteController.dispose();
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
      final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
      await timelineProvider.createTimelineEntry(noteController.text.trim());
    }

    noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.getThemeModeIcon()),
                onPressed: () => Navigator.pushNamed(context, '/theme-settings'),
              ),
            ],
          ),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
          if (authProvider.user?.partnerId == null) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      Icon(
                        Icons.timeline,
                        size: 64.0,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16.0),
                    Text(
                        'No Partner Connected',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Connect with a partner to start sharing your timeline',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to partner connection
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Connect with Partner'),
                      ),
                    ],
                  ),
                );
              }

              return Consumer<TimelineProvider>(
                builder: (context, timelineProvider, child) {
                  if (timelineProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final timeline = timelineProvider.timeline;

                  return timeline.isEmpty
                      ? Center(
                      child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.timeline,
                                size: 64.0,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'No timeline entries yet',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Start sharing moments with your partner',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24.0),
                              ElevatedButton.icon(
                                onPressed: _showCreateTimelineDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Entry'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: timeline.length,
                          itemBuilder: (context, index) {
                            final entry = timeline[index];
                            final isCurrentUser = entry.userId == authProvider.user?.id;
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                                    Row(
                  children: [
                                        CircleAvatar(
                                          backgroundColor: isCurrentUser
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[600],
                                          child: Icon(
                                            isCurrentUser ? Icons.person : Icons.favorite,
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
              Expanded(
        child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                                              Text(
                                                isCurrentUser ? 'You' : _getPartnerName(authProvider),
                                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: isCurrentUser
                                                      ? Theme.of(context).primaryColor
                                                      : Colors.grey[600],
                                                ),
                                              ),
            Text(
                                                _formatEntryTime(entry.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
                                      ],
                                    ),
                                    const SizedBox(height: 12.0),
                                    Text(
                                      entry.note,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                              if (entry.mediaUrl != null) ...[
                                      const SizedBox(height: 12.0),
          ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              entry.mediaUrl!,
                                          width: double.infinity,
                                          height: 200.0,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                                              height: 200.0,
                    color: Colors.grey[200],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48.0,
                                                  color: Colors.grey,
                                                ),
                  ),
                );
              },
            ),
          ),
                                    ],
                      ],
                    ),
                  ),
                            );
                          },
        );
      },
    );
            },
          ),
          floatingActionButton: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.user?.partnerId == null) {
                return const SizedBox.shrink();
              }
              
              return FloatingActionButton(
                onPressed: _showCreateTimelineDialog,
                child: const Icon(Icons.add),
              );
            },
          ),
        );
      },
    );
  }

  String _getPartnerName(AuthProvider authProvider) {
    // Try to get partner name from cached partner info
    final partnerInfo = authProvider.cachedPartnerInfo;
    if (partnerInfo != null && partnerInfo.username.isNotEmpty) {
      return partnerInfo.username;
    }
    return 'Partner';
  }

  String _formatEntryTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}