import 'package:eschool/app/routes.dart';
import 'package:eschool/cubits/authCubit.dart';
import 'package:eschool/cubits/bioAuthCubit.dart';
import 'package:eschool/cubits/resetPasswordRequestCubit.dart';
import 'package:eschool/cubits/signInCubit.dart';
import 'package:eschool/data/repositories/authRepository.dart';
import 'package:eschool/ui/screens/auth/widgets/requestResetPasswordBottomsheet.dart';
import 'package:eschool/ui/screens/auth/widgets/termsAndConditionAndPrivacyPolicyContainer.dart';
import 'package:eschool/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool/ui/widgets/customRoundedButton.dart';
import 'package:eschool/ui/widgets/customTextFieldContainer.dart';
import 'package:eschool/ui/widgets/passwordHideShowButton.dart';
import 'package:eschool/utils/biometric_utils.dart';
import 'package:eschool/utils/labelKeys.dart';
import 'package:eschool/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class StudentLoginScreenProvider extends StatelessWidget {
  const StudentLoginScreenProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(AuthRepository()),
      child: BlocProvider<BioAuthCubit>(
        create: (context) => BioAuthCubit(context.read<SignInCubit>()),
        child: const StudentLoginScreen(),
      ),
    );
  }
}

class StudentLoginScreen extends StatefulWidget {
  const StudentLoginScreen({Key? key}) : super(key: key);

  @override
  State<StudentLoginScreen> createState() => _StudentLoginScreenState();
}

class _StudentLoginScreenState extends State<StudentLoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );

  late final Animation<double> _patterntAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ),
  );

  late final Animation<double> _formAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ),
  );

  final TextEditingController _grNumberTextEditingController =
      TextEditingController(); //default grNumber

  final TextEditingController _passwordTextEditingController =
      TextEditingController(); //default password

  final _schoolCodeController = TextEditingController();

  bool _hidePassword = true;

  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _animationController.forward();
    _getAvailableBiometrics();
  }

  Future<void> _getAvailableBiometrics() async {
    _availableBiometrics = await BiometricUtils.getAvailableBiometrics();
    setState(() {});
  }

  @override
  void dispose() {
    _animationController.dispose();
    _grNumberTextEditingController.dispose();
    _passwordTextEditingController.dispose();
    super.dispose();
  }

  void _signInStudent() {
    if (_schoolCodeController.text.trim().isEmpty) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(
          Utils.getTranslatedLabel("pleaseEnterSchoolCode"),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_grNumberTextEditingController.text.trim().isEmpty) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseEnterGRNumberKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    if (_passwordTextEditingController.text.trim().isEmpty) {
      Utils.showCustomSnackBar(
        context: context,
        errorMessage: Utils.getTranslatedLabel(pleaseEnterPasswordKey),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
      return;
    }

    context.read<SignInCubit>().signInUser(
          userId: _grNumberTextEditingController.text.trim(),
          password: _passwordTextEditingController.text.trim(),
          schoolCode: _schoolCodeController.text.trim(),
          isStudentLogin: true,
        );
  }

  Future<void> _signInWithBiometrics() async {
    final bool canCheckBiometrics = await BiometricUtils.canCheckBiometrics();
    if (canCheckBiometrics) {
      final bool authenticated = await BiometricUtils.authenticate();
      if (authenticated) {
        context
            .read<BioAuthCubit>()
            .authenticateWithBiometrics(isStudent: true);
      }
    }
  }

  Widget _buildRequestResetPasswordContainer() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GestureDetector(
          onTap: () {
            Utils.showBottomSheet(
              child: BlocProvider(
                create: (_) => RequestResetPasswordCubit(AuthRepository()),
                child: const RequestResetPasswordBottomsheet(),
              ),
              context: context,
            ).then((value) {
              if (value != null && !value['error']) {
                Utils.showCustomSnackBar(
                  context: context,
                  errorMessage: Utils.getTranslatedLabel(
                    passwordResetRequestKey,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                );
              }
            });
          },
          child: Text(
            "${Utils.getTranslatedLabel(resetPasswordKey)}?",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildUpperPattern() {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: FadeTransition(
        opacity: _patterntAnimation,
        child: SlideTransition(
          position: _patterntAnimation.drive(
            Tween<Offset>(begin: const Offset(0.0, -1.0), end: Offset.zero),
          ),
          child: SvgPicture.asset(
            Utils.getImagePath("upper_pattern.svg"),
          ),
        ),
      ),
    );
  }

  Widget _buildLowerPattern() {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: FadeTransition(
        opacity: _patterntAnimation,
        child: SlideTransition(
          position: _patterntAnimation.drive(
            Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero),
          ),
          child: SvgPicture.asset(
            Utils.getImagePath("lower_pattern.svg"),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    if (_availableBiometrics.isEmpty) {
      return const SizedBox.shrink();
    }

    final biometricType = _availableBiometrics.contains(BiometricType.face)
        ? BiometricType.face
        : _availableBiometrics.first;

    final isFace = biometricType == BiometricType.face;

    return SizedBox(
      width: 50.0,
      height: 50.0,
      child: GestureDetector(
        onTap: _signInWithBiometrics,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary,
          ),
          child: isFace
              ? SvgPicture.asset(
                  "assets/images/faceID.svg",
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).scaffoldBackgroundColor,
                    BlendMode.srcIn,
                  ),
                )
              : Icon(
                  Icons.fingerprint,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Align(
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _formAnimation,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ), //to make UI scrollable when keyboard is opened
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: NotificationListener(
              onNotification: (OverscrollIndicatorNotification overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * (0.075),
                  right: MediaQuery.of(context).size.width * (0.075),
                  top: MediaQuery.of(context).size.height * (0.15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage("assets/images/skootureLogo.png"),
                      height: MediaQuery.of(context).size.width * 0.4,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      Utils.getTranslatedLabel(letsSignInKey),
                      style: TextStyle(
                        fontSize: 34.0,
                        fontWeight: FontWeight.bold,
                        color: Utils.getColorScheme(context).secondary,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "${Utils.getTranslatedLabel(welcomeBackKey)}, \n${Utils.getTranslatedLabel(youHaveBeenMissedKey)}",
                      style: TextStyle(
                        fontSize: 24.0,
                        height: 1.5,
                        color: Utils.getColorScheme(context).secondary,
                      ),
                    ),

                    /// School code field
                    const SizedBox(height: 30.0),
                    CustomTextFieldContainer(
                      hideText: false,
                      hintTextKey: Utils.getTranslatedLabel("schoolCode"),
                      bottomPadding: 0,
                      textEditingController: _schoolCodeController,
                    ),

                    /// GR number field
                    const SizedBox(height: 30.0),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFieldContainer(
                            hideText: false,
                            hintTextKey: grNumberKey,
                            bottomPadding: 0,
                            textEditingController:
                                _grNumberTextEditingController,
                            suffixWidget: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SvgPicture.asset(
                                Utils.getImagePath("user_icon.svg"),
                                colorFilter: ColorFilter.mode(
                                  Utils.getColorScheme(context).secondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(width: 10),
                        // _buildBiometricButton(),
                      ],
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    CustomTextFieldContainer(
                      textEditingController: _passwordTextEditingController,
                      suffixWidget: PasswordHideShowButton(
                        hidePassword: _hidePassword,
                        onTap: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                      hideText: _hidePassword,
                      hintTextKey: passwordKey,
                      bottomPadding: 0,
                    ),
                    _buildRequestResetPasswordContainer(),
                    const SizedBox(height: 30.0),
                    Center(
                      child: BlocConsumer<SignInCubit, SignInState>(
                        listener: (context, state) {
                          if (state is SignInSuccess) {
                            //
                            context.read<AuthCubit>().authenticateUser(
                                  schoolCode: state.schoolCode,
                                  jwtToken: state.jwtToken,
                                  isStudent: state.isStudentLogIn,
                                  parent: state.parent,
                                  student: state.student,
                                );

                            Get.offNamedUntil(
                                Routes.home, (Route<dynamic> route) => false);
                          } else if (state is SignInFailure) {
                            Utils.showCustomSnackBar(
                              context: context,
                              errorMessage:
                                  Utils.getTranslatedLabel(state.errorMessage),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            );
                          }
                        },
                        builder: (context, state) {
                          return CustomRoundedButton(
                            onTap: () {
                              if (state is SignInInProgress) {
                                return;
                              }
                              FocusScope.of(context).unfocus();

                              _signInStudent();
                            },
                            widthPercentage: 0.8,
                            backgroundColor:
                                Utils.getColorScheme(context).primary,
                            buttonTitle: Utils.getTranslatedLabel(signInKey),
                            titleColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            showBorder: false,
                            child: state is SignInInProgress
                                ? const CustomCircularProgressIndicator(
                                    strokeWidth: 2,
                                    widthAndHeight: 20,
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    BlocBuilder<SignInCubit, SignInState>(
                      builder: (context, state) {
                        return Center(
                          child: InkWell(
                            onTap: () {
                              if (state is SignInInProgress) {
                                return;
                              }
                              Get.offNamed(Routes.parentLogin);
                            },
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color:
                                          Utils.getColorScheme(context).primary,
                                    ),
                                    text: Utils.getTranslatedLabel(
                                      loginAsKey,
                                    ),
                                  ),
                                  const TextSpan(text: " "),
                                  TextSpan(
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16.0,
                                      color: Utils.getColorScheme(context)
                                          .secondary,
                                    ),
                                    text:
                                        "${Utils.getTranslatedLabel(parentKey)}?",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const TermsAndConditionAndPrivacyPolicyContainer(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * (0.025),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //to aboide the lower pattern from hiding login form when keyboard is open
      body: Stack(
        children: [
          _buildLowerPattern(),
          _buildUpperPattern(),
          _buildLoginForm(),
        ],
      ),
    );
  }
}
