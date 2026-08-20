#!/bin/bash
FILES=(
  "lib/ui/screens/parentHomeScreen.dart"
  "lib/ui/widgets/resultsContainer.dart"
  "lib/ui/widgets/settingsContainer.dart"
  "lib/utils/paymentWebview.dart"
)
for file in "${FILES[@]}"; do
  echo "=== $file ===" >> ui_diff_summary2.txt
  diff -u /Users/mohamedghaly/Desktop/SkootureStdentApp/SkootureStudent/$file /Users/mohamedghaly/Desktop/SkootureStdentApp/e-school-saas/e-school-saas/$file >> ui_diff_summary2.txt || true
done
