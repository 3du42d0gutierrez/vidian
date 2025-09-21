import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vidian_stream/domain/entities/content.dart';

/// Reusable card to display a content item in grids/lists.
class ContentCard extends StatelessWidget {
  final Content content;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;
  final bool small;
  final bool showCategory;
  final bool showPlayIcon;
  final String? heroTag;

  const ContentCard({
    Key? key,
    required this.content,
    this.isFavorite = false,
    this.onTap,
    this.onToggleFavorite,
    this.small = false,
    this.showCategory = true,
    this.showPlayIcon = true,
    this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double borderRadius = 8.0;
    final double thumbnailAspect = small ? 16 / 9 : 16 / 9;
    final textTheme = Theme.of(context).textTheme;

    final title = content.title ?? '';
    final logo = content.logo;
    final category = content.category ?? '';

    return Material(
      color: Theme.of(context).cardColor,
      elevation: 1,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: thumbnailAspect,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Thumbnail image or placeholder
                  if ((logo ?? '').isNotEmpty)
                    Hero(
                      tag: heroTag ?? 'content-thumb-${content.id}',
                      child: CachedNetworkImage(
                        imageUrl: logo!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: Center(
                            child: SizedBox(
                              width: small ? 24 : 32,
                              height: small ? 24 : 32,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          alignment: Alignment.center,
                          child: const Icon(Icons.broken_image, size: 36, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: Icon(Icons.tv, size: small ? 36 : 48, color: Colors.grey),
                    ),

                  // Dark gradient to make title readable
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.35),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Play icon overlay
                  if (showPlayIcon)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: small ? 44 : 56,
                        height: small ? 44 : 56,
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: small ? 28 : 34,
                          semanticLabel: 'Play',
                        ),
                      ),
                    ),

                  // Favorite button (se mantiene táctil, con tooltip y mayor hit area)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Semantics(
                      button: true,
                      label: isFavorite ? 'Remove favorite' : 'Add to favorites',
                      child: Tooltip(
                        message: isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                        child: Material(
                          color: Colors.black38,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              if (onToggleFavorite != null) onToggleFavorite!.call();
                            },
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0), // mayor área de toque
                              child: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.redAccent : Colors.white,
                                size: small ? 18 : 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title & metadata
            Padding(
              padding: EdgeInsets.symmetric(horizontal: small ? 8.0 : 10.0, vertical: small ? 8.0 : 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: small ? 2 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: small ? textTheme.bodyMedium : textTheme.titleMedium,
                  ),
                  if (showCategory && category.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}