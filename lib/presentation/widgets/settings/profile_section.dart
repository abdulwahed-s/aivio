import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsProfileSection extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onPickImage;
  final VoidCallback onEditName;

  const SettingsProfileSection({
    super.key,
    required this.profile,
    required this.onPickImage,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Appcolor.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: profile.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              profile.photoUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                if (kDebugMode) {
                                  print('Profile image error: $error');
                                }
                                return _buildDefaultAvatar();
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                            ),
                          )
                        : _buildDefaultAvatar(),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onPickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Appcolor.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: onEditName,
                        ),
                      ],
                    ),
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Text(
        profile.username.isNotEmpty ? profile.username[0].toUpperCase() : 'U',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Appcolor.primaryColor,
        ),
      ),
    );
  }
}
