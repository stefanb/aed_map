import 'package:aed_map/bloc/points/points_cubit.dart';
import 'package:aed_map/bloc/points/points_state.dart';
import 'package:aed_map/repositories/geolocation_repository.dart';
import 'package:aed_map/repositories/points_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PointsCubit', () {
    late PointsCubit pointsCubit;
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      pointsCubit = PointsCubit(
          pointsRepository: PointsRepository(),
          geolocationRepository: GeolocationRepository());
    });

    test('initial state is PointsLoadInProgress', () {
      expect(pointsCubit.state, PointsLoadInProgress());
    });

    test('load', () async {
      await pointsCubit.load();
      expect(pointsCubit.state, isA<PointsLoadSuccess>());
    });

    test('select', () async {
      await pointsCubit.load();
      var aed = (pointsCubit.state as PointsLoadSuccess).aeds.first;
      pointsCubit.select(aed);
      expect((pointsCubit.state as PointsLoadSuccess).selected, aed);
    });

    test('update', () async {
      await pointsCubit.load();
      var aed = (pointsCubit.state as PointsLoadSuccess).aeds.first;
      pointsCubit.update(aed);
      expect((pointsCubit.state as PointsLoadSuccess).selected, aed);
    });

    tearDown(() {
      pointsCubit.close();
    });
  });
}
