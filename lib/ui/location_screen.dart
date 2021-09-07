import 'dart:ffi';

//import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Location {
  late double latitude;
  late double longitude;

  Future<Void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      print(e);
    }
  }
}
