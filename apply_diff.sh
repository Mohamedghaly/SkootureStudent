#!/bin/bash
FILES=(
  "lib/data/models/schoolConfiguration.dart"
  "lib/data/repositories/authRepository.dart"
  "lib/data/repositories/feeRepository.dart"
  "lib/data/repositories/resultRepository.dart"
  "lib/data/repositories/schoolRepository.dart"
  "lib/data/repositories/studentRepository.dart"
  "lib/data/repositories/systemInfoRepository.dart"
  "lib/cubits/childFeeDetailsCubit.dart"
  "lib/cubits/resultsCubit.dart"
  "lib/cubits/resultsOnlineCubit.dart"
  "lib/cubits/schoolConfigurationCubit.dart"
  "lib/cubits/schoolGalleryCubit.dart"
)
for file in "${FILES[@]}"; do
  cp /Users/mohamedghaly/Desktop/SkootureStdentApp/e-school-saas/e-school-saas/$file ./$file
done
