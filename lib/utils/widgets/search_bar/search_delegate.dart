import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tpmobile/utils/widgets/overlay_loader.dart';

import '../../../models/osm_data.dart';
import '../../../services/osm_repository.dart';
import '../../../services/setup_di.dart';

class MySearchDelegate extends SearchDelegate {
  final OSMRepository _osmRepository = getIt<OSMRepository>();

  String? previousSearch;
  List<OSMDataCentroid>? marinas;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else {
                query = '';
              }
            },
            icon: const Icon(Icons.clear))
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back));

  @override
  Widget buildResults(BuildContext context) => Container();

  @override
  Widget buildSuggestions(BuildContext context) => StreamBuilder(
      stream: Stream.value(query),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData && previousSearch != snapshot.data) {
          previousSearch = snapshot.data;
          return FutureBuilder(
              future:
                  _osmRepository.getMarinasCentroidsByName(snapshot.data ?? ''),
              builder: (builder, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return OverlayLoader(message: 'Searching..');
                } else {
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (BuildContext builder, int index) => ListTile(
                        title: Text(snapshot.data?[index].name ?? ''),
                        onTap: () => close(context, snapshot.data?[index])),
                    separatorBuilder: (context, index) => const Divider(),
                  );
                }
              });
        } else {
          return Container();
        }
      });
}
