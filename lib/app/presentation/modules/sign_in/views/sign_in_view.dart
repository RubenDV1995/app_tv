import 'package:flutter/material.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            child: AbsorbPointer(
              absorbing: _fetching,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (text) {
                      setState(() {
                        _username = text.trim().toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(hintText: 'username'),
                    validator: (text) {
                      text = text?.trim().toLowerCase() ?? '';
                      if (text.isEmpty) {
                        return 'Invalid Username';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (text) {
                      setState(() {
                        _password = text.replaceAll(' ', '');
                      });
                    },
                    decoration: const InputDecoration(hintText: 'password'),
                    validator: (text) {
                      text = text?.replaceAll(' ', '') ?? '';
                      if (text.length < 4) {
                        return 'invalid Password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Builder(
                    builder: (context) {
                      if (_fetching == true) {
                        return const CircularProgressIndicator();
                      }
                      return MaterialButton(
                        onPressed: () {
                          final isValid = Form.of(context).validate();
                          if (isValid) {
                            _submit(context);
                          }
                        },
                        color: Colors.blue,
                        child: const Text('Sign In'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
