import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:immolink/features/auth/presentation/providers/auth_provider.dart';
import 'package:immolink/features/chat/domain/models/chat_message.dart';
import 'package:immolink/features/chat/presentation/providers/chat_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;

  const ChatPage({
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
    super.key,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesStream = ref.watch(chatMessagesProvider(widget.conversationId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: messagesStream.when(
              data: (messages) => _buildMessagesList(messages, currentUser?.id ?? ''),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load messages',
                      style: AppTypography.subhead.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildMessageInput(currentUser?.id ?? ''),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.1),
            backgroundImage: widget.otherUserAvatar != null 
                ? NetworkImage(widget.otherUserAvatar!) 
                : null,
            child: widget.otherUserAvatar == null
                ? Text(
                    widget.otherUserName.isNotEmpty 
                        ? widget.otherUserName[0].toUpperCase() 
                        : 'U',
                    style: AppTypography.subhead.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: AppTypography.subhead.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isTyping)
                  Text(
                    'typing...',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryAccent,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  Text(
                    'Online',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Implement video call
          },
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            // TODO: Implement voice call
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showChatOptions();
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList(List<ChatMessage> messages, String currentUserId) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _slideAnimation.value,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isMe = message.senderId == currentUserId;
              final showDate = index == 0 || 
                  !_isSameDay(message.timestamp, messages[index - 1].timestamp);
              
              return Column(
                children: [
                  if (showDate) _buildDateSeparator(message.timestamp),
                  _buildMessageBubble(message, isMe),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceCards,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _formatDate(date),
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: isMe
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryAccent,
                          AppColors.primaryAccent.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                color: isMe ? null : AppColors.surfaceCards,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: AppTypography.body.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 16,
                    color: message.isRead ? AppColors.primaryAccent : AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(String currentUserId) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.dividerSeparator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: AppColors.textSecondary),
              onPressed: () {
                HapticFeedback.lightImpact();
                _showAttachmentOptions();
              },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCards,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.dividerSeparator,
                    width: 0.5,
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textPlaceholder,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (text) {
                    setState(() {
                      _isTyping = text.isNotEmpty;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _sendMessage(currentUserId);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryAccent,
                      AppColors.primaryAccent.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String senderId) {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _messageController.clear();
    setState(() {
      _isTyping = false;
    });    // Create a new message to send
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      receiverId: '', // This would be set by the backend
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
    );

    // Send the message using the chat service
    ref.read(chatServiceProvider).sendMessage(message, widget.conversationId);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    HapticFeedback.lightImpact();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send Attachment',
              style: AppTypography.subhead.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [                _buildAttachmentOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  color: AppColors.primaryAccent,
                  onTap: () => _pickImage('camera'),
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.green,
                  onTap: () => _pickImage('gallery'),
                ),
                _buildAttachmentOption(
                  icon: Icons.attach_file,
                  label: 'Document',
                  color: Colors.orange,
                  onTap: _pickDocument,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }  void _pickImage(String source) async {
    try {
      HapticFeedback.lightImpact();
      final ImagePicker picker = ImagePicker();
      XFile? image;
      
      if (source == 'camera') {
        image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      } else {
        image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
      }
        if (image != null) {
        final selectedImage = image; // Capture non-null image
        // TODO: Upload image to cloud storage and get URL
        // For now, just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Image selected: ${selectedImage.name}'),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'SEND',
              textColor: Colors.white,
              onPressed: () {
                // Send image message
                _sendImageMessage(selectedImage.path, selectedImage.name);
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error picking image: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _pickDocument() async {
    try {
      HapticFeedback.lightImpact();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null) {
        final file = result.files.first;
        final fileSize = file.size;
        final maxSize = 10 * 1024 * 1024; // 10MB limit
        
        if (fileSize > maxSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('File size exceeds 10MB limit'),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        
        // TODO: Upload document to cloud storage and get URL
        // For now, just show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Document selected: ${file.name}'),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryAccent,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'SEND',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Send document message
                _sendDocumentMessage(file.path!, file.name);
              },
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error picking document: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _sendImageMessage(String imagePath, String imageName) {
    // TODO: Implement actual image upload and URL generation
    // For now, send a placeholder message
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: ref.read(currentUserProvider)?.id ?? '',
      receiverId: '', // This would be set by the backend
      content: '📷 Image: $imageName',
      timestamp: DateTime.now(),
      isRead: false,
    );

    ref.read(chatServiceProvider).sendMessage(message, widget.conversationId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Image sent successfully!'),
        backgroundColor: AppColors.primaryAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _sendDocumentMessage(String documentPath, String documentName) {
    // TODO: Implement actual document upload and URL generation
    // For now, send a placeholder message
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: ref.read(currentUserProvider)?.id ?? '',
      receiverId: '', // This would be set by the backend
      content: '📄 Document: $documentName',
      timestamp: DateTime.now(),
      isRead: false,
    );

    ref.read(chatServiceProvider).sendMessage(message, widget.conversationId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Document sent successfully!'),
        backgroundColor: AppColors.primaryAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showChatOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Chat Options',
              style: AppTypography.subhead.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppColors.primaryAccent),
              title: const Text('View Contact Info'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show contact info
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: AppColors.error),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Block user
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: AppColors.error),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Report user
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

