import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late YandexMapController controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YandexMap(
        tiltGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        scrollGesturesEnabled: true,
        modelsEnabled: true,
        nightModeEnabled: false,
        indoorEnabled: false,
        liteModeEnabled: false,
        onMapCreated: (YandexMapController yandexMapController) async {
          controller = yandexMapController;
          final cameraPosition = await controller.getCameraPosition().then(
            (value) async {
              await controller.moveCamera(CameraUpdate.newCameraPosition(
                  const CameraPosition(
                      target: Point(latitude: 41.2995, longitude: 69.2401),
                      zoom: 12.0)));
            },
          );
        },
      ),
    );
  }
}
