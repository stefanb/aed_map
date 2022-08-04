import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'models/aed.dart';

class Store {
  static Store instance = Store();

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Location permissions are denied');
    }
    if (permission == LocationPermission.deniedForever) return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    return await Geolocator.getCurrentPosition();
  }

  VectorTileProvider buildCachingTileProvider() {
    const urlTemplate = 'https://tiles.stadiamaps.com/data/openmaptiles/{z}/{x}/{y}.pbf?api_key=$tilesApiKey';
    return MemoryCacheVectorTileProvider(delegate: NetworkVectorTileProvider(urlTemplate: urlTemplate, maximumZoom: 14), maxSizeBytes: 1024 * 1024 * 32);
  }

  Future<List<AED>> loadAEDs() async {
    var response = await http.get(Uri.parse('https://aed.openstreetmap.org.pl/aed_poland.geojson'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load AEDs');
    }
    List<AED> aeds = [];
    var jsonList = jsonDecode(response.body)['features'];
    jsonList.forEach((row) {
      aeds.add(AED(LatLng(row['geometry']['coordinates'][1], row['geometry']['coordinates'][0]), row['properties']['osm_id'], row['properties']['defibrillator:location'],
          row['properties']['indoor'] == 'yes', row['properties']['operator'], row['properties']['phone']));
    });
    print('Loaded ${aeds.length} AEDs!');
    return aeds;
  }
}