import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maplocation/maplocation/const.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Location _locationcontroller = Location();

  Completer<GoogleMapController> _mapcontroller =
  Completer<GoogleMapController>();

  static LatLng _pGooglePlex = LatLng(23.2027842, 72.7870883);
  static LatLng _pAppleplex = LatLng(22.2027846, 72.7870889);

  LatLng? _currentP;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdate().then((_) {
      getPoliylinePoints().then((coordinates) {
        genratePolyLineFormPoints(coordinates);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? Center(child: Text("Loading....."))
          : GoogleMap(
        myLocationButtonEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _pGooglePlex,
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _mapcontroller.complete(controller);
        },
        markers: {
          Marker(
              markerId: MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _currentP!),
          Marker(
              markerId: MarkerId("_sourceLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pGooglePlex),
          Marker(
              markerId: MarkerId("_destinationLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pAppleplex)
        },
        polylines: Set<Polyline>.of(polylines.values),
      ),
    );
  }

  Future<void> _cameratopostion(LatLng pos) async {
    final GoogleMapController controller = await _mapcontroller.future;
    CameraPosition _newCameraPostion = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(
        CameraUpdate.newCameraPosition(_newCameraPostion));
  }

  Future<void> getLocationUpdate() async {
    bool _serviceisEnabled;
    PermissionStatus _permissionGranted;

    _serviceisEnabled = await _locationcontroller.serviceEnabled();
    if (_serviceisEnabled) {
      _serviceisEnabled = await _locationcontroller.requestService();
    } else {
      return;
    }
    _permissionGranted = await _locationcontroller.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationcontroller.requestPermission();
    }
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
    _locationcontroller.onLocationChanged.listen((
        LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print("Current Location ======== ${_currentP}");
          _cameratopostion(_currentP!);
        });
      }
    });
  }

  Future<List<LatLng>> getPoliylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Google_MAps_Keys,
        PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
        PointLatLng(_pAppleplex.latitude, _pAppleplex.longitude),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print("No polyline points found.");
      }
    } catch (e) {
      print("Error fetching polyline points: $e");
    }
    return polylineCoordinates;
  }

  void genratePolyLineFormPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      print("Polyline================$polyline");
      polylines[id] = polyline;
    });
  }
}