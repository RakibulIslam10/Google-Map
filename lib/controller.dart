import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeController extends GetxController {
  Rx<LatLng> myLocation = LatLng(23.8028, 90.4097).obs;
  RxDouble myLatitude = 0.0.obs;
  RxDouble myLongitude = 0.0.obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    checkAndAskLocationPermission();
  }


  late GoogleMapController mapController;

  Future<void> checkAndAskLocationPermission() async {
    isLoading.value = true;

    Location location = Location();
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();

    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();

      if (permission == PermissionStatus.deniedForever) {
        Get.defaultDialog(
          title: "Permission Required",
          middleText: "Please enable location permission from settings.",
          textConfirm: "Open Settings",
          confirmTextColor: Colors.white,
          onConfirm: () {
            AppSettings.openAppSettings();
            Get.back();
          },
        );
        return;
      }

      if (permission != PermissionStatus.granted) return;
    }
    isLoading.value = false;


    // Everything is fine – fetch location
    LocationData myLocationData = await location.getLocation();

    myLatitude.value = myLocationData.latitude ?? 23.8028;
    myLongitude.value = myLocationData.longitude ?? 90.4097;

    myLocation.value = LatLng(myLatitude.value, myLongitude.value);


    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: myLocation.value,
          zoom: 15,
        ),
      ),
    );
  }
}
