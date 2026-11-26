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
