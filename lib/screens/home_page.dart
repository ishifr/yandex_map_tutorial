import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late YandexMapController controller;
  final List<MapObject> mapObjects = [];
  final MapObjectId placemarkId = MapObjectId('normal_icon_placemark');
  Location location = Location();
  LocationData? currentPosition;

  @override
  void initState() {
    super.initState();
    getLocation();
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
        mapObjects: mapObjects,
        onMapTap: (Point point) {
          marker(
              latitude: point.latitude.toDouble(),
              longitude: point.longitude.toDouble());
        },
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on),
        backgroundColor: Colors.amber,
        
        onPressed: () async {
          await controller.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: Point(
                      latitude: currentPosition!.latitude!.toDouble(),
                      longitude: currentPosition!.longitude!.toDouble()),
                  zoom: 16.0)));

          marker(
              latitude: currentPosition!.latitude!.toDouble(),
              longitude: currentPosition!.longitude!.toDouble());
          print("latitude: ${currentPosition!.latitude!.toDouble()} ");
          print("longitude: ${currentPosition!.longitude!.toDouble()} ");
        },
      ),
    );
  }

  marker({latitude, longitude}) {
    if (mapObjects.isEmpty) {
      if (mapObjects.any((element) => element.mapId == placemarkId)) {
        return;
      }

      final placemark = Placemark(
        mapId: placemarkId,
        point: Point(latitude: latitude, longitude: longitude),
        onTap: (Placemark self, Point point) {
          print('Tapped me at $point');
        },
        direction: 0,
        opacity: 1,
        isDraggable: true,
        onDragStart: (_) => print('Drag start'),
        onDrag: (_, Point point) => print('Drag at point $point'),
        onDragEnd: (_) => print('Drag end'),
        icon: PlacemarkIcon.single(PlacemarkIconStyle(
            scale: 2.4,
            image:
                BitmapDescriptor.fromAssetImage('assets/img/location_icon.png'),
            rotationType: RotationType.noRotation)),
      );

      setState(() {
        mapObjects.add(placemark);
      });
    } else if (mapObjects.isNotEmpty) {
      if (!mapObjects.any((element) => element.mapId == placemarkId)) {
        return;
      }

      final placemarkUpdate =
          mapObjects.firstWhere((el) => el.mapId == placemarkId) as Placemark;
      setState(() {
        mapObjects[mapObjects.indexOf(placemarkUpdate)] =
            placemarkUpdate.copyWith(
          point: Point(latitude: latitude, longitude: longitude),
        );
      });
    }
  }

  Future getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentPosition = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        currentPosition = currentLocation;
      });
    });
  }
}
