import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/services/networking.dart';
import 'package:weather_app/ui/location_screen.dart';

const apikey = "b4154c2bc8ab7b3f40c876c8ce9bbb3d";
const openWetherMapURL = "https://api.openweathermap.org/data/2.5/weather";

class WeatherModel {
  Future<dynamic> getCityWeather(String cityName) async {
    NetworkHelper networkHelper = NetworkHelper(
        '$openWetherMapURL?q=$cityName&appid=$apikey&units=metric');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.gerCurrentLocation();

    NetworkHelper networkHelper = NetworkHelper(
        '$openWetherMapURL?lat=${location.latitude}&lon=${location.longitude}&appid=$apikey&units=metric');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }
}

class WeatherAppPage extends StatefulWidget {
  const WeatherAppPage({Key? key}) : super(key: key);

  @override
  _WeatherAppPageState createState() => _WeatherAppPageState();
}

class _WeatherAppPageState extends State<WeatherAppPage> {
  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          "Weather Updates",
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
      body: Center(
        child: Container(
          child: ElevatedButton(
            onPressed: getLocation,
            child: Text("Get Location"),
          ),
        ),
      ),
    );
  }
}
