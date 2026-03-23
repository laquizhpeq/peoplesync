import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback? onEditPhoto;

  const ProfileAvatar({
    super.key,
    this.photoUrl,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
          child: photoUrl == null ? const Icon(Icons.person, size: 60) : null,
        ),
        // Camera icon to change photo
        Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: onEditPhoto,
          ),
        ),
      ],
    );
  }
}
