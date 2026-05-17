enum AppStep { setup, sample, child, assets, generate }

AppStep resolveStartupConfigurationStep({
  required bool needsConfiguration,
  required bool wasRequired,
  required AppStep currentStep,
  required String? selectedChildId,
}) {
  if (needsConfiguration) return AppStep.setup;
  if (wasRequired && currentStep == AppStep.setup) return AppStep.child;
  if (currentStep == AppStep.assets && selectedChildId == null) {
    return AppStep.child;
  }
  return currentStep;
}
