import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'signInCubit.dart';

abstract class BioAuthState extends Equatable {
  const BioAuthState();

  @override
  List<Object> get props => [];
}

class BioAuthInitial extends BioAuthState {}

class BioAuthInProgress extends BioAuthState {}

class BioAuthSuccess extends BioAuthState {}

class BioAuthFailure extends BioAuthState {
  final String errorMessage;

  const BioAuthFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class BioAuthCubit extends Cubit<BioAuthState> {
  final SignInCubit _signInCubit;

  BioAuthCubit(this._signInCubit) : super(BioAuthInitial());

  Future<void> authenticateWithBiometrics() async {
    emit(BioAuthInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final password = prefs.getString('password');
      final isStudentLogin = prefs.getBool('isStudentLogin');
      final schoolCode = prefs.getString('schoolCode');

      if (userId != null &&
          password != null &&
          isStudentLogin != null &&
          schoolCode != null) {
        await _signInCubit.signInUser(
          userId: userId,
          password: password,
          isStudentLogin: isStudentLogin,
          schoolCode: schoolCode,
        );
        emit(BioAuthSuccess());
      } else {
        emit(const BioAuthFailure('No credentials found'));
      }
    } catch (e) {
      emit(BioAuthFailure(e.toString()));
    }
  }
}
