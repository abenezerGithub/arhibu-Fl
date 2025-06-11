import 'package:arhibu/features/chat/presentation/screens/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '2',
      title: 'Room Viewing Request',
      message: 'Sara Haile wants to schedule a viewing for your room.',
      time: '15 minutes ago',
      type: NotificationType.viewing,
      isRead: false,
      senderName: 'Sara Haile',
      senderAvatar: 'https://i.pravatar.cc/150?img=3',
      isOnline: true,
    ),
    NotificationItem(
      id: '3',
      title: 'New Message from Dawit',
      message:
          'The location works perfectly for me. Can we discuss the details?',
      time: '1 hour ago',
      type: NotificationType.message,
      isRead: true,
      senderName: 'Dawit Teklu',
      senderAvatar: 'https://i.pravatar.cc/150?img=4',
      isOnline: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Room Application',
      message: 'Martha Solomon has applied for your room listing.',
      time: '2 hours ago',
      type: NotificationType.application,
      isRead: true,
      senderName: 'Martha Solomon',
      senderAvatar: 'https://i.pravatar.cc/150?img=5',
      isOnline: true,
    ),
    NotificationItem(
      id: '5',
      title: 'New Message from Kebede',
      message: 'Thanks for the quick response! I\'ll get back to you soon.',
      time: '3 hours ago',
      type: NotificationType.message,
      isRead: true,
      senderName: 'Kebede Alemu',
      senderAvatar: 'https://i.pravatar.cc/150?img=2',
      isOnline: false,
    ),
    NotificationItem(
      id: '6',
      title: 'Room Listing Update',
      message: 'Your room listing has been viewed 25 times today.',
      time: '5 hours ago',
      type: NotificationType.system,
      isRead: true,
      senderName: 'System',
      senderAvatar: 'https://i.pravatar.cc/150?img=6',
      isOnline: false,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_searchQuery.isEmpty) return _notifications;
    return _notifications.where((notification) {
      return notification.title.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
          notification.message.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
          notification.senderName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final notification = _notifications.firstWhere(
        (n) => n.id == notificationId,
      );
      notification.isRead = true;
    });
  }

  void _navigateToChat(NotificationItem notification) {
    if (notification.type == NotificationType.message ||
        notification.type == NotificationType.viewing ||
        notification.type == NotificationType.application) {
      _markAsRead(notification.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            name: notification.senderName,
            avatarUrl: notification.senderAvatar,
            isOnline: notification.isOnline,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
          child: Image.asset(
            'images/Logowhite.png',
            width: 50,
            height: 50,
            color: const Color.fromARGB(255, 10, 89, 224),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[700]),
                ),
                style: TextStyle(color: Colors.blue),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        titleTextStyle: const TextStyle(
          color: Colors.blue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search, size: 24),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close, size: 24),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
        ],
      ),
      body: Container(
        color: Colors.grey[50],
        child: _filteredNotifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No notifications yet'
                          : 'No notifications found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isEmpty
                          ? 'You\'ll see notifications here when you receive messages or updates'
                          : 'Try adjusting your search terms',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = _filteredNotifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () => _navigateToChat(notification),
                  );
                },
              ),
      ),
    );
  }
}

enum NotificationType { message, viewing, application, system }

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  bool isRead;
  final String senderName;
  final String senderAvatar;
  final bool isOnline;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    required this.senderName,
    required this.senderAvatar,
    required this.isOnline,
  });
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.viewing:
        return Icons.visibility;
      case NotificationType.application:
        return Icons.assignment;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.viewing:
        return Colors.green;
      case NotificationType.application:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: notification.isRead
                ? Colors.white
                : Colors.blue.withOpacity(0.05),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(),
                  color: _getNotificationColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: notification.isRead
                                  ? Colors.black87
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (notification.type != NotificationType.system) ...[
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                              notification.senderAvatar,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            notification.senderName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: notification.isOnline
                                  ? Colors.green
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Spacer(),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
