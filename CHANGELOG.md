# Changelog

## [0.2.2](https://github.com/khaledeltarabily/pick_sheet_form_field/compare/v0.2.1...v0.2.2) (2026-11-27)


### Bug Fixes

* **sheet:** scroll instead of overflowing when space is tight ([62f0127](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/62f01270cb4c4180b3766d0884ee930668e0c206))
* **sheet:** scroll instead of overflowing when space is tight ([3b24eab](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/3b24eab528d05c11ca0626d769eb2f2597b794e0))

## [0.2.1](https://github.com/khaledeltarabily/pick_sheet_form_field/compare/v0.2.0...v0.2.1) (2026-11-27)


### Bug Fixes

* **sheet:** ignore a negative keyboard inset ([a16cbbd](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/a16cbbd1d94e3c0692feccda5c3b4b0299d3ee07))
* **sheet:** ignore a negative keyboard inset ([0ecb154](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/0ecb154147e1abb8e339e61714241415e021e439))

## [0.2.0](https://github.com/khaledeltarabily/pick_sheet_form_field/compare/v0.1.1...v0.2.0) (2026-11-26)


### ⚠ BREAKING CHANGES

* PickSheetConfig is no longer an InheritedWidget. Remove it from MaterialApp.builder and pass it as `config:` to each field or sheet (wrap the field in your own widget to share one config). Replace

### Features

* pass PickSheetConfig to the widget instead of the tree ([9cbc862](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/9cbc862f84de9a0b9e2e9c75207ae423b8b3bcb2))


### Bug Fixes

* drop unmatched values on reset and prevent toolbar overflow ([85a727c](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/85a727c6d8fb6eef7b60660eddcf2fdcfc10c6b9))
* drop unmatched values on reset and prevent toolbar overflow ([cc5c524](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/cc5c5245f11678a80893ace4777b81227212bba8))


### Performance Improvements

* **sheet:** stop rebuilding the sheet on every keyboard frame ([97ca73f](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/97ca73f850dcaacb633cc34805ab7d0b07745525))
* stop rebuilding the sheet on every keyboard frame ([4339192](https://github.com/khaledeltarabily/pick_sheet_form_field/commit/433919287f34a8b1853b3a2aa5c62265be6d881e))

## 0.1.1

- Add screenshots of the field and the sheet to the README and pub.dev page.
- Add the iOS runner to the example app.

## 0.1.0

Initial release.

- `PickSheetFormField`: a multi-select `FormField` that shows the selected
  values as removable chips and opens a bottom sheet to change them. Works
  with `validator`, `onSaved` and `Form.reset()`.
- `showPickSheet`: opens the same sheet without a field.
- Sheet with optional search, "All / Selected" tabs and
  "Select all / Clear all".
- `maxSelections` limits how many values can be picked; `maxSelections: 1`
  turns the field into a single-select.
- `PickSheetItem` (with `PickSheetItem.listOf`) to describe the options.
- `PickSheetStatus` to show a loading placeholder, offline and failure states
  while the items load.
- `PickSheetController` to read and change the selection from code.
- `PickSheetTheme` theme extension. Values left out come from the app's input
  decoration, bottom sheet and button themes, then from its `ColorScheme`.
- `PickSheetStrings` for translated texts (English fallbacks), and
  `PickSheetConfig` for app-wide texts and loading/empty builders.
