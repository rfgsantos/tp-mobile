import 'package:flutter/cupertino.dart';

import '../../services/authentication_repository.dart';
import '../../services/internet_connection.dart';
import '../../services/setup_di.dart';
import 'missing_widgets.dart';

class InternetAuthenticationChecker extends StatelessWidget {
  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();
  final InternetConnectionService _internetConnectionService =
      getIt<InternetConnectionService>();

  final Widget authenticatedWidget;
  final Widget internetFailing;
  final Widget authenticationFailing;

  InternetAuthenticationChecker(
      {super.key,
      required this.authenticatedWidget,
      Widget? internetFailing,
      Widget? authenticationFailing})
      : internetFailing = internetFailing ?? const InternetMissing(),
        authenticationFailing =
            authenticationFailing ?? const AuthenticationMissing();

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: _internetConnectionService.connectionStream,
      builder: (context, snapshot) => snapshot.data ?? false
          ? StreamBuilder(
              stream: _authenticationRepository.statusStream,
              builder: (context, snapshot) =>
                  snapshot.data == AuthenticationStatus.authenticated
                      ? authenticatedWidget
                      : authenticationFailing)
          : internetFailing);
}
