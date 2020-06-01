import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import 'PolygonModel.dart';
import 'package:flutter/widgets.dart';


void main() {
  runApp(MyApp());
}
// Main app class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: ChangeNotifierProvider<PolygonModel>(
        builder: (_) => PolygonModel(),
        child: MapView(),
      ),
    );
  }
}
// Class that contains the map view
class MapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Provider to call the polygon  Model class
    final polygonModel = Provider.of<PolygonModel>(context);
    // Open street url used by the map
    final openStreetUrl="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
    // Longitude and latitude
    double lat =48.427920;
    double long =-123.358090;


    return FutureBuilder<List<Polygon>>(
      //async call to laod polygon data from Model class
        future: polygonModel.getGeoJson(lat.toString(),long.toString()), // <--- get a future
        builder: (BuildContext context, snapshot) {
          // <--- build the things.
          //polygons.
          List<Polygon> polygons = snapshot.data ?? [];

          // UI code
          return Scaffold(
            appBar: AppBar(
              title: Text('Flutter Map'),
            ),
            body: Center(
                //Flutter Map class
                child: new FlutterMap(
                  // map options
              options: new MapOptions(
                center: new LatLng(lat, long),
                zoom: 8.0,
              ),
              layers: [
                new TileLayerOptions(
                    urlTemplate:
                    openStreetUrl,
                    subdomains: ['a', 'b', 'c']),
                //Polygon layers
                new PolygonLayerOptions(polygons: polygons),
              ],
            )),

          );
        });
  }
}
