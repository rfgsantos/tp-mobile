import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tpmobile/models/user.dart';
import 'package:tpmobile/pages/home/forms/login_form/login_form.dart';
import 'package:tpmobile/pages/home/forms/register_form/register_form_cubit.dart';
import 'package:tpmobile/pages/home/home.dart';
import 'package:tpmobile/services/internet_connection.dart';
import 'package:tpmobile/utils/widgets/internet_authentication.dart';
import 'package:tpmobile/utils/widgets/navigation_drawer/default_avatar.dart';

import '../../../pages/home/forms/login_form/login_form_cubit.dart';
import '../../../pages/home/forms/register_form/register_form.dart';
import '../../../pages/plans/plans_home.dart';
import '../../../pages/profile/profile_dialog.dart';
import '../../../pages/teams/teams_home.dart';
import '../../../services/authentication_repository.dart';
import '../../../services/setup_di.dart';
import '../../sidenav_route.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<StatefulWidget> createState() => _NavigationDrawer();
}

class _NavigationDrawer extends State<MyNavigationDrawer> {
  final List<SideNavRoute> routes = [
    SideNavRoute(
        route: HomePage.route,
        text: "Home",
        icon: Icons.home_outlined,
        page: const HomePage()),
    SideNavRoute(
        route: TeamsHomePage.route,
        text: "Teams",
        icon: Icons.groups_outlined,
        page: const TeamsHomePage()),
    SideNavRoute(
        route: PlansHomePage.route,
        text: "Plans",
        icon: Icons.map_outlined,
        page: const PlansHomePage()),
  ];

  final AuthenticationRepository _authenticationRepository =
      getIt<AuthenticationRepository>();

  final InternetConnectionService _internetConnectionService =
      getIt<InternetConnectionService>();

  static Route<void> _editProfile(context, arguments) {
    return MaterialPageRoute(
        builder: (context) => ProfileDialog(user: User.fromJson(arguments)),
        fullscreenDialog: true);
  }

  @override
  Widget build(BuildContext context) => Drawer(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeader(),
            _buildMenuItems(),
            const Spacer(),
            _buildLogout(),
          ],
        ),
      );

  Widget _buildHeader() => InternetAuthenticationChecker(
        authenticatedWidget: StreamBuilder(
            stream: _authenticationRepository.userStream,
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) =>
                snapshot.hasData
                    ? Container(
                        color: Colors.green,
                        child: Padding(
                            padding: EdgeInsets.only(
                                top: 24 + MediaQuery.of(context).padding.top,
                                bottom: 24),
                            child: Column(children: [
                              InkWell(
                                  onTap: () {
                                    /*function to profile*/
                                    print("clicked avatar");
                                    _authenticationRepository.printShared();
                                    Navigator.restorablePush<void>(
                                        context, _editProfile,
                                        arguments: snapshot.data?.toJson());
                                  },
                                  child: snapshot.data?.profile_image != null
                                      ? CircleAvatar(
                                          radius: 52,
                                          backgroundImage: Image.memory(
                                                  Base64Decoder().convert(
                                                      snapshot.data
                                                              ?.profile_image ??
                                                          ""))
                                              .image)
                                      : const DefaultAvatar()),
                              const SizedBox(height: 12),
                              Text(
                                  "${snapshot.data!.first_name} ${snapshot.data!.last_name}",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                  )),
                              Text(
                                snapshot.data!.email,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              )
                            ])))
                    : Container()),
        authenticationFailing: Container(
            color: Colors.green,
            child: Padding(
                padding: EdgeInsets.only(
                    top: 24 + MediaQuery.of(context).padding.top, bottom: 25),
                child: Column(children: [
                  const DefaultAvatar(),
                  const SizedBox(height: 12),
                  _authenticationLinks()
                ]))),
      );

  Widget _authenticationLinks() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        InkWell(
          onTap: () => _login(),
          child: const Text("Login",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.underline)),
        ),
        const Text("|", style: TextStyle(fontSize: 16, color: Colors.white)),
        InkWell(
          onTap: () => _register(),
          child: const Text("Register",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  decoration: TextDecoration.underline)),
        )
      ]);

  Widget _buildMenuItems() => Container(
      padding: const EdgeInsets.only(left: 15), child: _buildListTile());

  Widget _buildListTile() => ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: routes.length,
      itemBuilder: (context, index) => ListTile(
          leading: Icon(routes[index].icon),
          title: Text(routes[index].text),
          onTap: () =>
              Navigator.of(context).pushReplacementNamed(routes[index].route)));

  Widget _buildLogout() => InternetAuthenticationChecker(
        authenticatedWidget: Padding(
          padding: const EdgeInsets.all(20),
          child: TextButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              onPressed: _logout,
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              label: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              )),
        ),
        internetFailing: Container(),
        authenticationFailing: Container(),
      );

  void _login() {
    Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (context) => Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: AlertDialog(
                  scrollable: false,
                  title: const Text('Login'),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocProvider(
                        create: (_) => LoginFormCubit(),
                        child: const LoginForm()),
                  ),
                ))));
  }

  void _logout() {
    _authenticationRepository.logOut();
  }

  void _register() {
    Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (BuildContext context) => Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: AlertDialog(
                  scrollable: true,
                  title: const Text("Register"),
                  content: Padding(
                    padding: const EdgeInsets.all(8),
                    child: BlocProvider<RegisterFormCubit>(
                      create: (_) => RegisterFormCubit(),
                      child: const RegisterForm(),
                    ),
                  ),
                ))));
  }
}
