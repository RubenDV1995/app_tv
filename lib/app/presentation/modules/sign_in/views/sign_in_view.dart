import 'package:flutter/material.dart';
import 'package:ux_design_system/atoms/button/tdsm_general_button.dart';
import 'package:ux_design_system/atoms/input/tdsm_input.dart';
import 'package:ux_design_system/atoms/space/tdsm_standard_space.dart';
import 'package:ux_design_system/pages/sign_in/tdsm_page_standard_sign_in.dart';

import '../../../../../main.dart';
import '../../../../domain/enums.dart';
import '../../../routes/routes.dart';

class SingInView extends StatefulWidget {
  const SingInView({Key? key}) : super(key: key);

  @override
  State<SingInView> createState() => _SingInViewState();
}

class _SingInViewState extends State<SingInView> {
  String _username = '', _password = '';
  bool _fetching = false;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _fetching = true;
    });
    final result = await Injector.of(context).authenticationRepository.signIn(
          _username,
          _password,
        );

    if (!mounted) {
      return;
    }

    result.when(
      (failure) {
        setState(() {
          _fetching = false;
        });
        final message = {
          SignInFailure.notFound: 'Not found',
          SignInFailure.unauthorized: 'unauthorized',
          SignInFailure.unknown: 'unknown',
          SignInFailure.network: 'Network error'
        }[failure];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message!),
          ),
        );
      },
      (user) {
        Navigator.pushReplacementNamed(context, Routes.home);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TDSMPageStandardSignIn(
      header: Image.network('https://cdn.iconscout.com/icon/free/png-256/pepsi-226305.png'),
      actions: Form(
        child: AbsorbPointer(
          absorbing: _fetching,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TDSMInput(
                controller: usernameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                label: 'username',
                onChanged: (text) {
                  setState(() {
                    _username = text.trim().toLowerCase();
                  });
                },
                validator: (text) {
                  text = text?.trim().toLowerCase() ?? '';
                  if (text.isEmpty) {
                    return 'Invalid Username';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TDSMInput(
                controller: passwordController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                label: 'password',
                onChanged: (text) {
                  setState(() {
                    _password = text.replaceAll(' ', '');
                  });
                },
                validator: (text) {
                  text = text?.replaceAll(' ', '') ?? '';
                  if (text.length < 4) {
                    return 'invalid Password';
                  }
                  return null;
                },
              ),
              const TDSMStandardSpace(),
              Builder(
                builder: (context) {
                  if (_fetching == true) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    children: [
                      TDSMPrimaryButton(
                        text: 'Sign In',
                        onPressed: () {
                          final isValid = Form.of(context).validate();
                          if (isValid) {
                            _submit(context);
                          }
                        },
                      ),
                      const TDSMStandardSpace(),
                      TDSMSecondaryButton(
                        text: 'Sign Up',
                        onPressed: () {

                        },
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
