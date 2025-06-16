import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileImageWithLoader extends StatelessWidget {
  final String? imageUrl;
  final String placeholderImage;

  const ProfileImageWithLoader({
    super.key,
    this.imageUrl,
    this.placeholderImage = 'assets/images/default_profile.png',
  });

  @override
  Widget build(BuildContext context) {
    final isImageUrlValid = imageUrl != null && imageUrl!.isNotEmpty;

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[200],
      child: isImageUrlValid
          ? CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 50,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(placeholderImage),
        ),
      )
          : CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(placeholderImage),
      ),
    );
  }
}
