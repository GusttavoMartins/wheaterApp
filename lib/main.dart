// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(WheaterApp());
}

class WheaterApp extends StatelessWidget {

  Future<Map<String, dynamic>?> loadWeatherData() async {

    var queryParams = {
      "key": "81134a81c96740db958105843232808",
      "q":"-20.8,-49.38", // TODO: Obter os dados de localização do dispositivo.
      "lang": "pt",
    };

    var url = 
    Uri.https("api.weatherapi.com", "/v1/forecast.json", queryParams);

    var response = await http.get(url);
    print(response.statusCode);
    if(response.statusCode == 200) {
      var json = convert.jsonDecode(response.body) as Map<String, dynamic>;
      return json;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFF255AF4),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: loadWeatherData(),
          builder: (context, snapshot) {

            if(!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            var dados = snapshot.data!;
            var forecastday = dados['forecast']['forecastday'][0]['hour'] as List<dynamic>;

            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(dados['location']['name'], style: titleStyle),
                  Column(
                    children: [
                      Container(
                        child: Image.asset('images/01_sunny_color.png'),
                        width: 96,
                        height: 96,
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 24),
                      ),
                      Text(dados['current']['condition']['text'], style: titleStyle),
                      Text("${dados['current']['temp_c']}°C", style: temperatureStyle),
                    ],
                  ),
                  Container(
                    // margin: EdgeInsets.only(top: 71),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Image.asset('images/humidity.png'),
                            Text("Humidity", style: iconStyle),
                            Text("${dados['current']['humidity']}%", style: iconStyle),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('images/wind.png'),
                            Text("Wind", style: iconStyle),
                            Text("${dados['current']['wind_kph']}km/h", style: iconStyle),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset('images/feels_like.png'),
                            Text("Feels Like", style: iconStyle),
                            Text("${dados['current']['feelslike_c']}°C", style: iconStyle),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 100,
                    // margin: EdgeInsets.only(top: 80),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: forecastday
                      .where((item) => DateTime.parse(item['time']).hour >= DateTime.now().hour - 3)
                      .map((item) => 
                        ForecastDay(item['time'], "chuva", item['temp_c'])).toList(),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class ForecastDay extends StatelessWidget {
  String timeEpoch;
  String image;
  double temperature;
  String? hour;

  ForecastDay(this.timeEpoch, this.image, this.temperature) {
    var data = DateTime.parse(timeEpoch);
    this.hour = data.hour.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 39),
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hour!, style: hourStyle),
          Image.asset('images/$image.png', width: 36, height: 36),
          Text("$temperature°", style: hourTemperatureStyle)
        ],
      ),
    );
  }
}
