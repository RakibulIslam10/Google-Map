import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeController extends GetxController {
  Rx<LatLng> myLocation = LatLng(23.8028, 90.4097).obs;
  RxDouble myLatitude = 0.0.obs;
  RxDouble myLongitude = 0.0.obs;
  RxBool isLoading = true.obs;
  RxString currentPlaceName = ''.obs; // জায়গার নাম
  RxString fullAddress = ''.obs; // ফুল অ্যাড্রেস

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
        CameraPosition(target: myLocation.value, zoom: 15),
      ),
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      myLatitude.value,
      myLongitude.value,
    );
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;

      print("🏠 Street      : ${place.street}");
      print("🏘️ Area        : ${place.subLocality}");
      print("🏙️ City        : ${place.locality}");
      print("🌍 District    : ${place.subAdministrativeArea}");
      print("🌐 State       : ${place.administrativeArea}");
      print("📮 Postal Code : ${place.postalCode}");
      print("🇧🇩 Country     : ${place.country}");

      currentPlaceName.value =
          "${place.street}, ${place.subLocality}"; // e.g., "Road 10, Banasree"

      fullAddress.value =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}, ${place.postalCode}";

      print(currentPlaceName.value);
      print(fullAddress.value);
    }
  }
}
