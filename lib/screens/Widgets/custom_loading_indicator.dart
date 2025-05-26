import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  /// Hiển thị loading indicator dạng sóng (wave) với màu xanh mặc định
  const CustomLoadingIndicator({
    super.key,
    this.size = 50.0,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: SpinKitWave(color: color, size: size));
  }
}
