import 'package:flutter/material.dart';
import 'package:flutter_app/core/i18n/strings.g.dart';
import 'package:flutter_app/core/widgets/not_found_view.dart';

/// Unknown route or non-numeric product id: a message and a way back to `/`.
class NotFoundPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.t.appTitle)),
      body: const NotFoundView(),
    );
  }
}
