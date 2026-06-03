import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';

import 'app_network_image.dart';

/// Displays the image extracted from a URL's link preview metadata.
class AppLinkPreviewThumbnail extends StatefulWidget {
  const AppLinkPreviewThumbnail({
    super.key,
    required this.url,
    required this.fallbackBuilder,
    this.fallbackImageUrl,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String url;
  final String? fallbackImageUrl;
  final BoxFit fit;
  final String? semanticLabel;
  final WidgetBuilder fallbackBuilder;

  @override
  State<AppLinkPreviewThumbnail> createState() =>
      _AppLinkPreviewThumbnailState();
}

class _AppLinkPreviewThumbnailState extends State<AppLinkPreviewThumbnail> {
  late Future<String?> _previewImageUrl;

  @override
  void initState() {
    super.initState();
    _previewImageUrl = _loadPreviewImageUrl();
  }

  @override
  void didUpdateWidget(covariant AppLinkPreviewThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _previewImageUrl = _loadPreviewImageUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _previewImageUrl,
      builder: (context, snapshot) {
        final previewImageUrl = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done &&
            previewImageUrl == null) {
          return widget.fallbackBuilder(context);
        }

        if (previewImageUrl == null || previewImageUrl.isEmpty) {
          return _buildFallback(context);
        }

        return AppNetworkImage(
          imageUrl: previewImageUrl,
          fit: widget.fit,
          width: double.infinity,
          height: double.infinity,
          semanticLabel: widget.semanticLabel,
          errorWidget: (_, _, _) => _buildFallback(context),
        );
      },
    );
  }

  Future<String?> _loadPreviewImageUrl() async {
    final previewData = await getLinkPreviewData(widget.url);
    return previewData?.image?.url.trim();
  }

  Widget _buildFallback(BuildContext context) {
    final fallbackImageUrl = widget.fallbackImageUrl;
    if (fallbackImageUrl == null || fallbackImageUrl.isEmpty) {
      return widget.fallbackBuilder(context);
    }

    return AppNetworkImage(
      imageUrl: fallbackImageUrl,
      fit: widget.fit,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: widget.semanticLabel,
      errorWidget: (_, _, _) => widget.fallbackBuilder(context),
    );
  }
}
