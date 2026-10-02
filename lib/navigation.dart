import 'package:flutter/material.dart';

import 'data/models/glucose_reading.dart';
import 'data/models/insulin_meal_hba1c.dart';
import 'domain/app_state.dart';
import 'features/glucose/glucose_editor_page.dart';
import 'features/insulin/insulin_editor_page.dart';
import 'features/more/hba1c_page.dart';
import 'features/more/meal_editor_page.dart';

/// Fonctions de navigationcentralisées (WBS lot 4.2).
Future<void> openGlucoseEditor(BuildContext context, AppState state, [GlucoseReading? existing]) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => GlucoseEditorPage(state: state, existing: existing)),
  );
}

Future<void> openInsulinEditor(BuildContext context, AppState state, [InsulinEntry? existing]) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => InsulinEditorPage(state: state, existing: existing)),
  );
}

Future<void> openMealEditor(BuildContext context, AppState state, [Meal? existing]) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => MealEditorPage(state: state, existing: existing)),
  );
}

Future<void> openHba1cPage(BuildContext context, AppState state) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => Hba1cPage(state: state)),
  );
}
