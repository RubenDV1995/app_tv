import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            Injector.of(context).authenticationRepository.signOut();
            Navigator.pushReplacementNamed(
              context,
              Routes.signIn,
            );
          },
          child: const Text('Sing Out'),
        ),
      ),
    );
  }
}
