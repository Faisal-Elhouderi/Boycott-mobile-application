import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  MobileScannerController? _controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      setState(() => _isScanning = false);
      context.go('/scan/${barcode!.rawValue}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay
          CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Scan frame
          Center(
            child: Container(
              width: 280,
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Stack(
                children: [
                  // Corner indicators
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _CornerIndicator(isTop: true, isLeft: true),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _CornerIndicator(isTop: true, isLeft: false),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: _CornerIndicator(isTop: false, isLeft: true),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: _CornerIndicator(isTop: false, isLeft: false),
                  ),
                ],
              ),
            ),
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              onPressed: () => context.pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),

          // Torch button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: IconButton(
              onPressed: () => _controller?.toggleTorch(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withOpacity(0.5),
              ),
              icon: ValueListenableBuilder(
                valueListenable: _controller!.torchState,
                builder: (context, state, child) {
                  return Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.pointCameraAtBarcode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerIndicator extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerIndicator({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CornerPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    
    // Calculate cutout rect
    const cutoutWidth = 280.0;
    const cutoutHeight = 180.0;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2;
    
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

