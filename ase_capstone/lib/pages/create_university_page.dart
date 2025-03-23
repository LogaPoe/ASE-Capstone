import 'package:ase_capstone/components/textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateUniversityPage extends StatefulWidget {
  const CreateUniversityPage({super.key});

  @override
  State<CreateUniversityPage> createState() => _CreateUniversityPageState();
}

class _CreateUniversityPageState extends State<CreateUniversityPage> {
  GoogleMapController? _controller;
  LatLng? _universityLocation;

  void _startTutorial(GoogleMapController controller) {
    _controller = controller;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Tutorial'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tap on the map to select a location for the university.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _setUniversityLocation(LatLng location) {
    // user already has a location selected

    setState(() {
      _universityLocation = location;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Selected Successfully'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('You have selected a location for the university.'),
                SizedBox(height: 10),
                Text(
                  'Latitude: ${_universityLocation!.latitude}\nLongitude: ${_universityLocation!.longitude}',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _zoomToLocation(location: _universityLocation!, zoom: 14);
                  // _setUniversityBounds();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _deleteUniversityLocation() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Location'),
            content:
                const Text('Are you sure you want to delete this location?'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _universityLocation = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
            ],
          );
        });
  }

  void _setUniversityBounds() {
    // TODO
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set University Bounds'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Next, tap '),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _zoomToLocation({required LatLng location, required double zoom}) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(
        _universityLocation!,
        14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create University'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
        child: Stack(
          children: [
            GoogleMap(
              onMapCreated: _startTutorial,
              initialCameraPosition: CameraPosition(
                target: LatLng(40, -96),
              ),
              zoomControlsEnabled: false,
              onTap: _setUniversityLocation,
              onLongPress: (location) {
                // TODO: setting buildings option
                print(
                    '_universityLocation:::::::::::::::::::::::: $_universityLocation');
              },
            ),
            _universityLocation != null
                ? Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      color: Colors.black,
                      child: Row(
                        children: [
                          IconButton(
                              icon: Icon(
                                Icons.location_on,
                                color: Colors.blue[400],
                                size: 20,
                              ),
                              onPressed: () {
                                _zoomToLocation(
                                  location: _universityLocation!,
                                  zoom: 14,
                                );
                              }),
                          Text(
                            'University Location: ${_universityLocation!.latitude.toStringAsFixed(1)}, ${_universityLocation!.longitude.toStringAsFixed(1)}',
                          ),
                          SizedBox(width: 10),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red[400],
                              size: 20,
                            ),
                            onPressed: _deleteUniversityLocation,
                          )
                        ],
                      ),
                    ),
                  )
                : Text(''),
          ],
        ),
      ),
    );
  }
}
