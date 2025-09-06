import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/timeline_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/timeline.dart';

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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateTimelineDialog(),
    );

    if (result == true) {
      // The dialog will handle the creation internally
    }
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
                      : _buildTimelineView(timeline, authProvider);
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

  Widget _buildTimelineView(List<TimelineEntry> timeline, AuthProvider authProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      itemCount: timeline.length,
      itemBuilder: (context, index) {
        final entry = timeline[index];
        final isCurrentUser = entry.userId == authProvider.user?.id;
        final isLast = index == timeline.length - 1;
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: _buildTimelineEntry(entry, isCurrentUser, isLast, authProvider),
        );
      },
    );
  }

  Widget _buildTimelineEntry(TimelineEntry entry, bool isCurrentUser, bool isLast, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and avatar
          Column(
            children: [
              _buildTimelineAvatar(entry, isCurrentUser),
              if (!isLast) _buildTimelineLine(),
            ],
          ),
          const SizedBox(width: 16.0),
          // Content
          Expanded(
            child: _buildTimelineContent(entry, isCurrentUser, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineAvatar(TimelineEntry entry, bool isCurrentUser) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isCurrentUser
              ? [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)]
              : [Colors.pink.shade400, Colors.pink.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCurrentUser ? Theme.of(context).primaryColor : Colors.pink.shade400).withOpacity(0.3),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isCurrentUser ? Icons.person : Icons.favorite,
        color: Colors.white,
        size: 24.0,
      ),
    );
  }

  Widget _buildTimelineLine() {
    return Container(
      width: 2.0,
      height: 40.0,
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(1.0),
      ),
    );
  }

  Widget _buildTimelineContent(TimelineEntry entry, bool isCurrentUser, AuthProvider authProvider) {
    return Container(
      margin: EdgeInsets.only(
        left: isCurrentUser ? 0 : 20.0,
        right: isCurrentUser ? 20.0 : 0,
      ),
      child: Card(
        elevation: 4.0,
        shadowColor: (isCurrentUser ? Theme.of(context).primaryColor : Colors.pink.shade400).withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            gradient: LinearGradient(
              colors: isCurrentUser
                  ? [Colors.white, Colors.grey.shade50]
                  : [Colors.pink.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and time
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrentUser ? 'You' : _getPartnerName(authProvider),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser
                                  ? Theme.of(context).primaryColor
                                  : Colors.pink.shade600,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.0,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                _formatEntryTime(entry.createdAt),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Decorative element
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: (isCurrentUser ? Theme.of(context).primaryColor : Colors.pink.shade400).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Icon(
                        isCurrentUser ? Icons.edit_note : Icons.favorite_border,
                        color: isCurrentUser ? Theme.of(context).primaryColor : Colors.pink.shade400,
                        size: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Note content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    entry.note,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                // Media if available
                if (entry.mediaUrl != null) ...[
                  const SizedBox(height: 16.0),
                  _buildMediaContent(entry.mediaUrl!),
                ],
                // Footer with reactions and actions
                const SizedBox(height: 12.0),
                _buildTimelineFooter(entry, isCurrentUser, authProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent(String mediaUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.network(
          mediaUrl,
          width: double.infinity,
          height: 200.0,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 48.0,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineFooter(TimelineEntry entry, bool isCurrentUser, AuthProvider authProvider) {
    // Only the owner can edit/delete their own entries
    final canEdit = isCurrentUser;
    
    return Column(
      children: [
        // Top row with reactions and date
        Row(
          children: [
            // Like button
            _buildReactionButton(
              icon: (entry.isLiked ?? false) ? Icons.favorite : Icons.favorite_border,
              count: entry.likes ?? 0,
              isActive: entry.isLiked ?? false,
              onTap: () => _handleLikeAction(entry),
              color: Colors.red,
            ),
            const SizedBox(width: 6.0),
            // Love button
            _buildReactionButton(
              icon: (entry.isLoved ?? false) ? Icons.favorite : Icons.favorite_border,
              count: entry.loves ?? 0,
              isActive: entry.isLoved ?? false,
              onTap: () => _handleLoveAction(entry),
              color: Colors.pink,
            ),
            const Spacer(),
            // Date badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                _formatDate(entry.createdAt),
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        // Action buttons row (only if user can edit)
        if (canEdit) ...[
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Edit button
              GestureDetector(
                onTap: () => _showEditTimelineDialog(entry),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 14.0,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Edit',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              // Delete button
              GestureDetector(
                onTap: () => _showDeleteConfirmation(entry),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete,
                        size: 14.0,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.red.shade600,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildReactionButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16.0),
          border: isActive ? Border.all(color: color.withOpacity(0.3)) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isActive),
                size: 14.0,
                color: isActive ? color : Colors.grey.shade600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4.0),
              Text(
                count.toString(),
                style: TextStyle(
                  color: isActive ? color : Colors.grey.shade600,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleLikeAction(TimelineEntry entry) async {
    final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
    
    try {
      if (entry.isLiked ?? false) {
        await timelineProvider.unlikeTimelineEntry(entry.id);
      } else {
        await timelineProvider.likeTimelineEntry(entry.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update like: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleLoveAction(TimelineEntry entry) async {
    final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
    
    try {
      if (entry.isLoved ?? false) {
        await timelineProvider.unloveTimelineEntry(entry.id);
      } else {
        await timelineProvider.loveTimelineEntry(entry.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update love: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditTimelineDialog(TimelineEntry entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditTimelineDialog(entry: entry),
    );

    if (result == true) {
      // The dialog will handle the update internally
    }
  }

  Future<void> _showDeleteConfirmation(TimelineEntry entry) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            const Text('Delete Entry'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this timeline entry? This action cannot be undone.',
          style: TextStyle(
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
              await timelineProvider.deleteTimelineEntry(entry.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateTimelineDialog extends StatefulWidget {
  @override
  _CreateTimelineDialogState createState() => _CreateTimelineDialogState();
}

class _CreateTimelineDialogState extends State<_CreateTimelineDialog> {
  late TextEditingController _noteController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        Icons.edit_note,
                        color: Theme.of(context).primaryColor,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Share a Moment',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'Add a new entry to your timeline',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                // Text field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20.0),
                    ),
                    maxLines: 4,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please share something with your partner';
                      }
                      if (value.trim().length > 500) {
                        return 'Note must be 500 characters or less';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
                            await timelineProvider.createTimelineEntry(_noteController.text.trim());
                            Navigator.of(context).pop(true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Share',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditTimelineDialog extends StatefulWidget {
  final TimelineEntry entry;

  const _EditTimelineDialog({required this.entry});

  @override
  _EditTimelineDialogState createState() => _EditTimelineDialogState();
}

class _EditTimelineDialogState extends State<_EditTimelineDialog> {
  late TextEditingController _noteController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.entry.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Colors.blue.shade600,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Entry',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'Update your timeline entry',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24.0),
                // Text field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10.0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20.0),
                    ),
                    maxLines: 4,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please share something with your partner';
                      }
                      if (value.trim().length > 500) {
                        return 'Note must be 500 characters or less';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24.0),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final timelineProvider = Provider.of<TimelineProvider>(context, listen: false);
                            await timelineProvider.updateTimelineEntry(
                              widget.entry.id,
                              _noteController.text.trim(),
                              mediaUrl: widget.entry.mediaUrl,
                            );
                            Navigator.of(context).pop(true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 2.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save,
                              size: 18.0,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8.0),
                            Text(
                              'Update',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}