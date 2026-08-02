import 'package:flutter/material.dart';

import 'pages/custom_keyboard_page.dart';
import 'pages/dialog_page.dart';
import 'pages/form_page.dart';
import 'pages/integrated_bar_page.dart';
import 'pages/large_list_page.dart';
import 'pages/material2_page.dart';
import 'pages/nested_scroll_page.dart';
import 'pages/sheet_page.dart';
import 'pages/simple_page.dart';
import 'pages/theming_page.dart';

void main() => runApp(const KeyboardActionsGalleryApp());

class KeyboardActionsGalleryApp extends StatelessWidget {
  const KeyboardActionsGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keyboard Actions 5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B4D3E)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const _Home(),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final demos = <_Demo>[
      _Demo('Done only', 'Zero config: login / OTP / phone', Icons.check,
          (_) => const SimplePage()),
      _Demo('Form + navigation', 'Prev / Next / Done / Submit', Icons.list_alt,
          (_) => const FormPage()),
      _Demo('Theming', 'Colors, height, labels, icons via theme',
          Icons.color_lens_outlined, (_) => const ThemingPage()),
      _Demo(
          'Integrated bar',
          'Flush toolbar, integratedBar: true',
          Icons.vertical_align_bottom_outlined,
          (_) => const IntegratedBarPage()),
      _Demo('Material 2', 'Classic theme: underline fields, M2 toolbar',
          Icons.palette_outlined, (_) => const Material2Page()),
      _Demo('Large ListView', '50+ fields, no scroll hacks', Icons.view_list,
          (_) => const LargeListPage()),
      _Demo('Custom keyboards', 'Numeric / counter / color panels',
          Icons.keyboard_alt_outlined, (_) => const CustomKeyboardPage()),
      _Demo('Dialog', 'Works inside AlertDialog', Icons.chat_bubble_outline,
          (_) => const DialogPage()),
      _Demo('Bottom sheet', 'Checkout-style modal sheet',
          Icons.vertical_align_bottom, (_) => const SheetPage()),
      _Demo('Nested scroll', 'CustomScrollView + slivers', Icons.layers,
          (_) => const NestedScrollPage()),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Keyboard Actions 5')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final d = demos[i];
          return Card(
            child: ListTile(
              leading: Icon(d.icon),
              title: Text(d.title),
              subtitle: Text(d.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: d.builder),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
  const _Demo(this.title, this.subtitle, this.icon, this.builder);
}
