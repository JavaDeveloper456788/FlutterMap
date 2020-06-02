import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import 'PolygonModel.dart';
import 'package:flutter/widgets.dart';
import 'package:poly/poly.dart' as customPolygon;
import 'package:rflutter_alert/rflutter_alert.dart';

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
    final openStreetUrl = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
    // Longitude and latitude
    double lat = 48.427920;
    double long = -123.358090;


    return FutureBuilder<List<Polygon>>(
        //async call to load polygon data from Model class
        future: polygonModel.getGeoJson(lat.toString(), long.toString()),
        // <--- get a future
        builder: (BuildContext context, snapshot) {
          // <--- build the things.
          //polygons.
          List<Polygon> polygons = snapshot.data ?? [];
          //convert flutter map polygons to custom polygons from third party library used to do polygon maths
          List<customPolygon.Polygon> _polygons= polygonModel.initPolygons( polygons );
          String polygonName= "";

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
                onTap: (LatLng point) {
                  String polygonName = "Clicked outside Polygon";
                  //Loop through polygons to find if point is inside polygon
                  for (var i = 0; i < _polygons.length; i++) {
                    if (_polygons[i].isPointInside(new customPolygon.Point(point.latitude, point.longitude))== true){
                      polygonName= polygonModel. getPolygonName( polygons[i]);
                      break;
                    }
                  }

                  // Text window to display polygon name
                  showDialog(
                      context: context,
                      child: new AlertDialog(
                        contentPadding: EdgeInsets.all(0),
                        content: Container(
                          height:100,
                        child: Row(
                        children : <Widget>[
                          Expanded(
                            child: Text(
                              polygonName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                         Align(
                            alignment: Alignment.topRight,
                            child: Container(
                            child: IconButton(
                                icon: new Icon(Icons.close),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                            ),
                          ),
                        ],

                      ),
                        ),

                      ));
                },
              ),
              layers: [
                new TileLayerOptions(
                    urlTemplate: openStreetUrl, subdomains: ['a', 'b', 'c']),
                //Polygon layers
                new PolygonLayerOptions(
                  polygons: polygons,
                ),
              ],
            )),
          );
        });
  }

}
