import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_map_project/controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends GetView<HomeController> {
  HomePage({super.key});

  @override
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.myLocation.value.latitude == 0 && controller.myLocation.value.longitude == 0) {
          // Location not ready, loading দেখাও
          return Center(child: CircularProgressIndicator());
        }
        return GoogleMap(
          initialCameraPosition: CameraPosition(
            target: controller.myLocation.value,
            zoom: 13,
          ),
          markers: {
            Marker(
              markerId: MarkerId('CurrentLocation'),
              position: controller.myLocation.value,
            ),
          },
          onMapCreated: (mapCtrl) {
            controller.mapController = mapCtrl;
          },
        );
      }),
    );
  }

}
