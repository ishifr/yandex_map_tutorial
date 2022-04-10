import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
// import 'package:js/js.dart';

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
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          YandexMap(
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
          Positioned(
              // top: getH(30.0),
              child: SizedBox(
            child: searchBarUI(),
          )),
        ],
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

  Widget searchBarUI() {
    return FloatingSearchBar(
      hint: 'Search.....',
      openAxisAlignment: 0.0,
      width: 600,
      axisAlignment: 0.0,
      scrollPadding: EdgeInsets.only(top: 16, bottom: 20),
      elevation: 4.0,
      physics: BouncingScrollPhysics(),
      onQueryChanged: (query) {
        //Your methods will be here
        print(query);
        var info = findPlaces(query: query);
      },
      transitionCurve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 400),
      transition: CircularFloatingSearchBarTransition(),
      debounceDelay: Duration(milliseconds: 300),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: Icon(Icons.place),
            onPressed: () {
              print('Places Pressed');
            },
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Material(
            color: Colors.white,
            child: Container(
              height: 200.0,
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    title: Text('Home'),
                    subtitle: Text('more info here........'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  findPlaces({String? query}) async {
    final results = YandexSearch.searchByText(
        searchText: query!,
        geometry: const Geometry.fromBoundingBox(BoundingBox(
          southWest:
              Point(latitude: 55.76996383933034, longitude: 37.57483142322235),
          northEast: Point(
              latitude: 55.785322774728414, longitude: 37.590924677311705),
        )),
        searchOptions: const SearchOptions(
          searchType: SearchType.geo,
          geometry: false,
          userPosition: Point(latitude: 41.311158, longitude: 69.279737),
        ));

    SearchSessionResult res = await results.result;

    return info(data: res.items);
  }

  info({data}) {
    List list = [];
    for (var r in data) {
      r.items.asMap().forEach((i, item) {
        list.add(i);
        print("$i");
      });
    }

    return list;
  }
}
// 41.311158, 69.279737