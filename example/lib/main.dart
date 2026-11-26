import 'package:flutter/material.dart';
import 'package:pick_sheet_form_field/pick_sheet_form_field.dart';

void main() => runApp(const ExampleApp());

/// Shows a pick sheet field inside a form.
class ExampleApp extends StatelessWidget {
  /// Creates the example app.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const ExamplePage(),
    );
  }
}

/// A form with one multi-select field.
class ExamplePage extends StatefulWidget {
  /// Creates the page.
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  static const _cities = [
    'Alexandria',
    'Aswan',
    'Cairo',
    'Giza',
    'Luxor',
    'Port Said',
    'Suez',
  ];

  final _formKey = GlobalKey<FormState>();
  List<String> _selected = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('pick_sheet_form_field')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            PickSheetFormField<String>(
              items: PickSheetItem.listOf(
                _cities,
                label: (city) => city,
                icon: Icons.location_city_rounded,
              ),
              labelText: 'Cities',
              searchEnabled: true,
              onChanged: (cities) => setState(() => _selected = cities),
              validator: (cities) =>
                  cities!.isEmpty ? 'Pick at least one city' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _formKey.currentState!.validate(),
              child: const Text('Validate'),
            ),
            const SizedBox(height: 16),
            Text('Selected: ${_selected.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
