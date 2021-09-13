import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  List<int> minTemperatureForecast = List.filled(7, 0);
  List<int> maxTemperatureForecast = List.filled(7, 0);
  String location = 'San Francisco';
  int woeid = 2487956;
  String weather = 'clear';
  String abbreviation = '';
  List<String> abbreviationForecast = List.filled(7, '');
  String errorMessage = '';

  final Geolocator geolocator = Geolocator();

  late Position _currentPosition;
  final TextEditingController _controller = TextEditingController();

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';

  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(Uri.parse(searchApiUrl + input));
      // var searchResult = await http.get(Uri.parse(
      //     "https://api.openweathermap.org/data/2.5/weather?q=" +
      //         input +
      //         "&appid=9e1adfc7ab7416ed1cac82f5af610a62"));
      var result = json.decode(searchResult.body)[0];

      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        errorMessage = '';
      });
    } catch (error) {
      setState(() {
        errorMessage =
            "Sorry, we don't have data about this city. Try another one.";
      });
    }
  }

  void fetchLocation() async {
    var locationResult =
        await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ', '').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void fetchLocationDay() async {
    var today = new DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(Uri.parse(locationApiUrl +
          woeid.toString() +
          '/' +
          new DateFormat('y/M/d')
              .format(today.add(new Duration(days: i + 1)))
              .toString()));
      var result = json.decode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTemperatureForecast[i] = data["min_temp"].round();
        maxTemperatureForecast[i] = data["max_temp"].round();
        abbreviationForecast[i] = data["weather_state_abbr"];
      });
    }
  }

  void onTextFieldSubmitted(String input) async {
    fetchSearch(input);
    fetchLocation();
    fetchLocationDay();
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await GeocodingPlatform.instance
          .placemarkFromCoordinates(
              _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {});
      onTextFieldSubmitted(place.locality.toString());
      print(place.locality);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.6), BlendMode.dstATop),
          ),
        ),
        // ignore: unnecessary_null_comparison
        child: temperature == null
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                appBar: AppBar(
                  actions: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          _getCurrentLocation();
                        },
                        child: Icon(Icons.location_city, size: 36.0),
                      ),
                    )
                  ],
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (String input) {
                              onTextFieldSubmitted(input);
                              _controller.clear();
                            },
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            decoration: InputDecoration(
                              hintText: 'Search another location...',
                              hintStyle: TextStyle(
                                  color: Colors.white, fontSize: 18.0),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(right: 20.0, left: 20.0),
                          child: Text(errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: Platform.isAndroid ? 15.0 : 20.0)),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Center(
                          child: Image.network(
                            'https://www.metaweather.com/static/img/weather/png/' +
                                abbreviation +
                                '.png',
                            width: 100,
                          ),
                        ),
                        Center(
                          child: Text(
                            temperature.toString() + ' °C',
                            style:
                                TextStyle(color: Colors.white, fontSize: 60.0),
                          ),
                        ),
                        Center(
                          child: Text(
                            location,
                            style:
                                TextStyle(color: Colors.white, fontSize: 40.0),
                          ),
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          for (var i = 0; i < 7; i++)
                            forecastElement(
                                i + 1,
                                abbreviationForecast[i],
                                minTemperatureForecast[i],
                                maxTemperatureForecast[i]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, minTemperature, maxTemperature) {
  var now = new DateTime.now();
  var oneDayFromNow = now.add(new Duration(days: daysFromNow));
  return Padding(
    padding: const EdgeInsets.only(left: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(205, 212, 228, 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Text(
              new DateFormat.E().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            Text(
              new DateFormat.MMMd().format(oneDayFromNow),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviation +
                    '.png',
                width: 50,
              ),
            ),
            Text(
              'High: ' + maxTemperature.toString() + ' °C',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            Text(
              'Low: ' + minTemperature.toString() + ' °C',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
        ),
      ),
    ),
  );
}
