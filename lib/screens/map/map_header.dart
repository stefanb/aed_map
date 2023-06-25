import 'package:aed_map/bloc/edit/edit_cubit.dart';
import 'package:aed_map/bloc/edit/edit_state.dart';
import 'package:aed_map/bloc/feedback/feedback_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_cubit.dart';
import 'package:aed_map/bloc/network_status/network_status_state.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../bloc/panel/panel_cubit.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';

class MapHeader extends StatelessWidget {
  const MapHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.heading,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
              BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
                if (state is PointsLoadSuccess) {
                  return Text(AppLocalizations.of(context)!.subheading(state.aeds.length),
                      style: const TextStyle(fontSize: 14));
                } else {
                  return Text(AppLocalizations.of(context)!.subheading(0), style: const TextStyle(fontSize: 14));
                }
              }),
              const SizedBox(height: 2),
              BlocBuilder<NetworkStatusCubit, NetworkStatusState>(builder: (context, state) {
                if (state.connected) return const SizedBox();
                return Text(AppLocalizations.of(context)!.noNetwork,
                    style: const TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold));
              })
            ],
          ),
          Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _showAboutDialog(context);
                },
                child: Card(
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.gear,
                        color:
                            MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              BlocListener<EditCubit, EditState>(
                listener: (BuildContext context, state) {
                  if (state.enabled) {
                    context.read<PanelCubit>().hide();
                  }
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    context.read<EditCubit>().enter();
                  },
                  child: Card(
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.black : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(CupertinoIcons.wand_rays,
                          color: MediaQuery.of(context).platformBrightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  BetterFeedback.of(context).show((UserFeedback feedback) {
                    context.read<FeedbackCubit>().send(feedback);
                  });
                },
                child: Card(
                  color: MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.black : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(CupertinoIcons.text_bubble,
                        color:
                            MediaQuery.of(context).platformBrightness == Brightness.dark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }

  _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationIcon: const Image(image: AssetImage('assets/icon.png'), width: 64),
      applicationName: AppLocalizations.of(context)!.heading,
      applicationVersion: 'v1.0.2',
      applicationLegalese: 'By Mateusz Woźniak',
      children: <Widget>[
        Padding(padding: const EdgeInsets.only(top: 15), child: Text(AppLocalizations.of(context)!.about)),
      ],
    );
  }
}
