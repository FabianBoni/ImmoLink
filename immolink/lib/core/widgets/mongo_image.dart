import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class MongoImage extends StatefulWidget {
  final String imageId;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final bool forceReload;

  const MongoImage({
    Key? key,
    required this.imageId,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
    this.loadingWidget,
    this.forceReload = false,
  }) : super(key: key);

  @override
  State<MongoImage> createState() => _MongoImageState();
}

class _MongoImageState extends State<MongoImage> {
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _imageBytes;
  String? _dataUrl;  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(MongoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageId != widget.imageId || widget.forceReload) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (kIsWeb) {
        // For web, use the base64 endpoint
        await _loadImageAsBase64();
      } else {
        // For mobile, use direct HTTP request
        await _loadImageAsBytes();
      }
    } catch (e) {
      print('Error loading MongoDB image: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }
  Future<void> _loadImageAsBase64() async {
    // Add cache buster to ensure fresh load
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/images/base64/${widget.imageId}?v=$cacheBuster'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Loading base64 image for ID: ${widget.imageId}, Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _dataUrl = data['dataUrl'];
        _isLoading = false;
      });
      print('Base64 image loaded successfully');
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }
  Future<void> _loadImageAsBytes() async {
    // Add cache buster to ensure fresh load
    final cacheBuster = DateTime.now().millisecondsSinceEpoch;
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/images/${widget.imageId}?v=$cacheBuster'),
    );

    print('Loading image bytes for ID: ${widget.imageId}, Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      setState(() {
        _imageBytes = response.bodyBytes;
        _isLoading = false;
      });
      print('Image bytes loaded successfully');
    } else {
      throw Exception('Failed to load image: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (_hasError) {
      return widget.errorWidget ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  'Failed to load image',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
    }

    if (kIsWeb && _dataUrl != null) {
      // For web, use Image.network with data URL
      return Image.network(
        _dataUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          print('Data URL image error: $error');
          return widget.errorWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
        },
      );
    } else if (_imageBytes != null) {
      // For mobile, use Image.memory
      return Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          print('Memory image error: $error');
          return widget.errorWidget ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              );
        },
      );
    }

    return widget.errorWidget ??
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
  }
}
