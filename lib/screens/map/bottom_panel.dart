import 'package:aed_map/bloc/panel/panel_cubit.dart';
import 'package:cross_fade/cross_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/location/location_cubit.dart';
import '../../bloc/location/location_state.dart';
import '../../bloc/points/points_cubit.dart';
import '../../bloc/points/points_state.dart';
import '../../bloc/routing/routing_cubit.dart';
import '../../bloc/routing/routing_state.dart';
import '../../models/aed.dart';
import '../../store.dart';
import '../../utils.dart';
import '../edit_form.dart';

class BottomPanel extends StatelessWidget {
  const BottomPanel({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PointsCubit, PointsState>(
      listener: (context, state) {
        if (state is PointsStateLoaded) {
          context.read<PanelCubit>().open();
          // panel.open();
          // _animatedMapMove(state.selected.location, 16);
        }
      },
      child: BlocBuilder<PointsCubit, PointsState>(builder: (context, state) {
        if (state is PointsStateLoading) {
          return Container();
        }
        if (state is PointsStateLoaded) {
          return ListView(
            padding: const EdgeInsets.all(0),
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 24.0),
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.aeds.first == state.selected)
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _selectAED(context, state.aeds.first);
                            },
                            child: Text(
                                '⚠️ ${AppLocalizations.of(context)!.closestAED}',
                                key: const Key('closestAed'),
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 18)),
                          ),
                        if (state.aeds.first != state.selected)
                          GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                _selectAED(context, state.aeds.first);
                              },
                              child: Text(
                                  '⚠️ ${AppLocalizations.of(context)!.closerAEDAvailable}',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 18))),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            if (!await Store.instance.authenticate()) return;
                            AED updatedAed = await Navigator.of(context).push(
                                CupertinoPageRoute(
                                    builder: (context) => EditForm(
                                        aed: state.selected, isEditing: true)));

                            int index = state.aeds
                                .indexWhere((x) => x.id == updatedAed.id);
                            state.aeds[index] = updatedAed;
                            // setState(() {
                            //   _editMode = false;
                            // });
                            // markersController
                            //     .replaceAll(_getMarkers(state.aeds));
                            context.read<PanelCubit>().show();
                            _selectAED(context, updatedAed);
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.dark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12))),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 4, bottom: 4),
                                child: Text(AppLocalizations.of(context)!.edit,
                                    style: TextStyle(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black)),
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: state.selected.getColor(),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: SvgPicture.asset(
                                          'assets/${state.selected.getIconFilename()}',
                                          width: 32)),
                                  const SizedBox(width: 6),
                                  Text(
                                      AppLocalizations.of(context)!
                                          .defibrillator,
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: state.selected.getColor() ==
                                                  Colors.yellow
                                              ? Colors.black
                                              : Colors.white))
                                ],
                              ),
                              const SizedBox(height: 8),
                              CrossFade<String>(
                                  duration: const Duration(milliseconds: 200),
                                  value: state.selected
                                          .getAccessComment(context)
                                          .purge() ??
                                      AppLocalizations.of(context)!.noData,
                                  builder: (context, v) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                            "${AppLocalizations.of(context)!.access}: ",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    state.selected.getColor() ==
                                                            Colors.yellow
                                                        ? Colors.black
                                                        : Colors.white)),
                                        Text(v,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    state.selected.getColor() ==
                                                            Colors.yellow
                                                        ? Colors.black
                                                        : Colors.white)),
                                      ],
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CrossFade<String>(
                        duration: const Duration(milliseconds: 200),
                        value: state.selected.description.purge() ??
                            AppLocalizations.of(context)!.noData,
                        builder: (context, v) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.location,
                                  style: const TextStyle(fontSize: 16)),
                              Text(v,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          );
                        }),
                    const SizedBox(height: 4),
                    CrossFade<String>(
                        duration: const Duration(milliseconds: 200),
                        value: state.selected.operator.purge() ??
                            AppLocalizations.of(context)!.noData,
                        builder: (context, v) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.operator,
                                  style: const TextStyle(fontSize: 16)),
                              Text(v,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          );
                        }),
                    const SizedBox(height: 4),
                    CrossFade<String>(
                        duration: const Duration(milliseconds: 200),
                        value: formatOpeningHours(state.selected.openingHours)
                                .purge() ??
                            AppLocalizations.of(context)!.noData,
                        builder: (context, v) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.openingHours,
                                  style: const TextStyle(fontSize: 16)),
                              Text(v,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          );
                        }),
                    const SizedBox(height: 4),
                    CrossFade<bool>(
                        duration: const Duration(milliseconds: 200),
                        value: state.selected.indoor,
                        builder: (context, v) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                  '${AppLocalizations.of(context)!.insideBuilding}: ',
                                  style: const TextStyle(fontSize: 16)),
                              Text(
                                  v
                                      ? AppLocalizations.of(context)!.yes
                                      : AppLocalizations.of(context)!.no,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          );
                        }),
                    const SizedBox(height: 4),
                    CrossFade<String>(
                        duration: const Duration(milliseconds: 200),
                        value: state.selected.phone.purge() ??
                            AppLocalizations.of(context)!.noData,
                        builder: (context, v) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              launchUrl(Uri.parse(
                                  'tel:${state.selected.phone.toString().replaceAll(' ', '')}'));
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                    '${AppLocalizations.of(context)!.contact}: ',
                                    style: const TextStyle(fontSize: 16)),
                                Text(v,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }),
                    const SizedBox(height: 10),
                    SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<LocationCubit, LocationState>(
                            builder: (context, locationState) {
                          if (locationState is LocationStateLocated) {
                            return BlocBuilder<RoutingCubit, RoutingState>(
                                builder: (context, routingCubitState) {
                              if (routingCubitState
                                  is RoutingStateCalculating) {
                                return IgnorePointer(
                                  child: Opacity(
                                    opacity: 0.5,
                                    child: CupertinoButton.filled(
                                        key: const Key('navigate'),
                                        onPressed: () async {
                                          context.read<RoutingCubit>().navigate(
                                              locationState.location,
                                              state.selected);
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .calculatingRoute)),
                                  ),
                                );
                              }
                              return CupertinoButton.filled(
                                  key: const Key('navigate'),
                                  onPressed: () async {
                                    context.read<RoutingCubit>().navigate(
                                        locationState.location, state.selected);
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!.navigate));
                            });
                          }
                          return Container();
                        })),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        }
        return Container();
      }),
    );
  }

  _selectAED(BuildContext context, AED aed) async {
    context.read<RoutingCubit>().cancel();
    context.read<PointsCubit>().select(aed);
    context.read<PanelCubit>().show();
  }
}
