# Build fix
This version fixes:
- runtime Theme.of(...) used inside a const Flutter Border
- accidental `pw.Tableflutter.Border.all` replacement in the PDF table code

Run:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```
