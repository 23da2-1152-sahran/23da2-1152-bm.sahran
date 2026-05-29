import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Simple web debugging page - add this to verify images work
/// Usage: Navigator.push(context, MaterialPageRoute(builder: (_) => WebImageTestPage()))
class WebImageTestPage extends StatefulWidget {
  const WebImageTestPage({super.key});

  @override
  State<WebImageTestPage> createState() => _WebImageTestPageState();
}

class _WebImageTestPageState extends State<WebImageTestPage> {
  final List<String> testAssets = [
    'assets/sculptural_wool_overcoat.png',
    'assets/archival_leather_bag.png',
    'assets/essential_linen_shirt.png',
    'assets/structured_linen_blazer.png',
    'assets/ribbed_cashmere_knit.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🖼️ Web Image Test'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Testing Image Loading',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Platform: ${kIsWeb ? "🌐 WEB (Browser)" : "📱 MOBILE (Phone)"}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Images should load from assets/ directory',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Test each asset
            ...testAssets.asMap().entries.map((entry) {
              int index = entry.key;
              String assetPath = entry.value;
              String fileName =
                  assetPath.split('/').last.replaceAll('.png', '');

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${index + 1}. $fileName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  // Image container
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.red[50],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image_not_supported,
                                  size: 48, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load',
                                style: TextStyle(color: Colors.red[700]),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  assetPath,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (kIsWeb)
                                Text(
                                  'Web Issue: Check F12 Console',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.red[600],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Asset path
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    child: SelectableText(
                      assetPath,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            }),

            // Console Instructions
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  border: Border.all(color: Colors.amber[700]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔍 Debugging Tips',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Press F12 to open Developer Tools',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '2. Go to Console tab',
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '3. Look for errors starting with:',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const SelectableText(
                        'Failed to load resource\nCORS error\n404 not found',
                        style: TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Expected Result',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    kIsWeb
                        ? 'On Web: All images should display (after flutter clean)'
                        : 'On Mobile: All images should display',
                  ),
                  SizedBox(height: 8),
                  if (!kIsWeb)
                    Text(
                      '✅ Images display fine on mobile',
                      style: TextStyle(color: Colors.green),
                    )
                  else
                    Text(
                      'If images still don\'t show, run:\nflutter clean && flutter pub get && flutter run -d chrome',
                      style: TextStyle(fontSize: 11),
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
