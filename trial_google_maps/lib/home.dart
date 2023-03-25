

// import 'dart:html';
// import 'dart:js';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trial_google_maps/object_detect.dart';

class Home extends StatefulWidget {
  Home({Key? key, required this.cameras}) : super(key: key);

  List<CameraDescription> cameras;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  // get cameras => widget.cameras;


  Position? _position = Position(longitude: 72.84793849278007, latitude: 19.018255973653343, timestamp: DateTime.now(), accuracy: 1, altitude: 10, heading: 2, speed: 10, speedAccuracy: 10);
  
  GoogleMapController? _controller;
  Uint8List? _imageBytes;

  @override
  void initState(){
    super.initState();
    _getCurrentLocation();
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    _controller = controller;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

  // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getCurrentLocation() async {
    _position = await _determinePosition();
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_position!.latitude, _position!.longitude),
          zoom: 11.0,
        ),
      ),
    );
  }


  static final LatLng _kMapCenter =
      LatLng(19.018255973653343, 72.84793849278007);

  static final CameraPosition _kInitialPosition =
      CameraPosition(target: _kMapCenter, zoom: 11.0,  tilt: 0, bearing: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trial"),
      ),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              InkWell(
                onTapDown: ((details) async {
                  _getCurrentLocation();
                  final imageBytes = await _controller?.takeSnapshot();
                  setState(() {
                    _imageBytes = imageBytes!;
                    
                  });
                }),
                child: Container(
                  // padding: const EdgeInsets.all(10),
                  height: 300,
                  width: double.infinity,
                  // color: Colors.amber,
                  child: GoogleMap(
                    onMapCreated: onMapCreated,
                    initialCameraPosition: _kInitialPosition,
                    // mapType: MapType.satellite,
                    myLocationEnabled: true,
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                    color: Colors.blueGrey[50], border: Border.all(width: 3)),
                height: 150,
                width: 120,
                margin: EdgeInsets.all(8),
                child: _imageBytes != null ? Image.memory(_imageBytes!) : null,
              ),

              // Align(
              //   alignment: AlignmentDirectional.bottomStart,
              //   child: Padding(
              //     padding: const EdgeInsets.all(40.0),
              //     child: FloatingActionButton(
              //       onPressed: () async {
              //         final imageBytes = await _controller?.takeSnapshot();
              //         setState(() {
              //           _imageBytes = imageBytes;
              //         });
              //       },
              //       child: Icon(Icons.fullscreen),
              //     ),
              //   )
              // ),

            ],
          ),
          Text("Current Location: " + _position!.latitude.toString() + ", "+ _position!.longitude.toString()),

          TextButton(
            onPressed: () {
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => ObjectDetectPage(cameras: widget.cameras))
              );
            },
            child: Text("Go to Object Detection", style: TextStyle(fontSize: 16),)
          )
        ],

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final imageBytes = await _controller?.takeSnapshot();
          setState(() {
            _imageBytes = imageBytes!;
          });
        },
        child: Icon(Icons.fullscreen),
      )
    );
    
  }
}

// class Home extends StatelessWidget {
//   const Home({Key? key}) : super(key: key);

//   static final LatLng _kMapCenter =
//       LatLng(19.018255973653343, 72.84793849278007);

//   static final CameraPosition _kInitialPosition =
//       CameraPosition(target: _kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Trial"),
//       ),
//       body: Column(
//         children: [
//           Container(
//             height: 300,
//             width: double.infinity,
//             // color: Colors.amber,
//             child: GoogleMap(
//               initialCameraPosition: _kInitialPosition,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }