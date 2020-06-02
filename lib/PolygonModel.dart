import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
//Third party library used to do polygon maths
import 'package:poly/poly.dart' as customPolygon;


//Main model class to load polygons from API
class PolygonModel with ChangeNotifier {
  //Hashmap to find polygon name
  Map<Polygon, String>  polygonsNames = new Map<Polygon, String>();
  // API url
  String URL='https://native-land.ca/api/index.php?maps=languages,territories,treaties&position=';

//main method to call the API, return a list of polygons. Arguments lat: latitude, long:longitude
  Future<List<Polygon>> getGeoJson(String lat, String long)  async{
    //API call
    final response = await http.get(URL+lat+','+long);
    final List<Polygon> polygons= new List<Polygon>();
    if (response.statusCode==200) {
      //Parse JSON data
      List<dynamic> list = json.decode(response.body);
      for (var i = 0; i < list.length; i++) {
        Map<String, dynamic> map = list[i];
        var features = map["geometry"] as Map<String, dynamic>;
        var properties = map["properties"] as Map<String, dynamic>;
        Color color;
        String name="";
        //get  properties
        properties.forEach((key, value) {
          //get color
          if (key == "color") {
            color = hexToColor(value);
          }
          // get Polygon name
          if (key == "Name") {
            name = value;
          }
        });
        //get coordinates

        List<LatLng> _points = new List<LatLng>();

        features.forEach((key, value) {
          if (key == "coordinates") {
            for (var i = 0; i < value.length; i++) {
              for (var j = 0; j < value[i].length; j++) {
                LatLng _point = new LatLng(value[i][j][1], value[i][j][0]);
                _points.add(_point);
              }
            }
          }
          if ((key == "type") && (value == "Polygon")) {
          //create new Polygon
          Polygon polygon = new Polygon(
              color: color,
              points: _points,

          );

          //Add polygon to list
          polygons.add(polygon);
          polygonsNames[polygon]= name;
        }
          });

      }
    }

    return polygons;
}
// Return Polygon name
 String getPolygonName(Polygon polygon){
    return  polygonsNames[polygon];

 }
// Method to convert Color code to hex
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000).withOpacity(.2);
  }

  // Method to convert flutter map polygons to custom polygons from third party library used to do polygon maths
  List<customPolygon.Polygon> initPolygons(List<Polygon> polygons ){
    List<customPolygon.Polygon> _polygons= new  List<customPolygon.Polygon>();
    for (var i = 0; i < polygons.length; i++) {
      List<customPolygon.Point<num>>_points = new List<customPolygon.Point<num>>();

      for (var j = 0; j < polygons[i].points.length; j++) {

        _points.add(new  customPolygon.Point(polygons[i].points[j].latitude, polygons[i].points[j].longitude));
      }
      _polygons.add(new customPolygon.Polygon(_points));
    }
    return _polygons;

  }


}