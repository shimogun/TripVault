import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsService {
  static GoogleMapController? _mapController;

  // 位置情報の許可を確認・取得
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 位置情報サービスが有効かチェック
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // 現在位置を取得
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Get Current Location Error: $e');
      return null;
    }
  }

  // 住所から座標を取得
  static Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      print('Get LatLng from Address Error: $e');
      return null;
    }
  }

  // 座標から住所を取得
  static Future<String?> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.street}, ${place.locality}, ${place.country}';
      }
      return null;
    } catch (e) {
      print('Get Address from LatLng Error: $e');
      return null;
    }
  }

  // 2点間の距離を計算（km）
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    ) / 1000; // メートルをキロメートルに変換
  }

  // マップコントローラーを設定
  static void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  // 指定位置にマップを移動
  static Future<void> moveToLocation(LatLng location, {double zoom = 15.0}) async {
    if (_mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: zoom,
          ),
        ),
      );
    }
  }

  // マーカーを作成
  static Marker createMarker({
    required String markerId,
    required LatLng position,
    required String title,
    String? description,
    BitmapDescriptor? icon,
    VoidCallback? onTap,
  }) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
        title: title,
        snippet: description,
      ),
      icon: icon ?? BitmapDescriptor.defaultMarker,
      onTap: onTap,
    );
  }

  // 複数の場所を表示するためのカメラ位置を計算
  static CameraPosition calculateCameraPosition(List<LatLng> locations) {
    if (locations.isEmpty) {
      return const CameraPosition(
        target: LatLng(0, 0),
        zoom: 2,
      );
    }

    if (locations.length == 1) {
      return CameraPosition(
        target: locations.first,
        zoom: 15,
      );
    }

    double minLat = locations.first.latitude;
    double maxLat = locations.first.latitude;
    double minLng = locations.first.longitude;
    double maxLng = locations.first.longitude;

    for (LatLng location in locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    double centerLat = (minLat + maxLat) / 2;
    double centerLng = (minLng + maxLng) / 2;

    return CameraPosition(
      target: LatLng(centerLat, centerLng),
      zoom: 12,
    );
  }

  // 観光スポットの検索（実際のAPIでは外部サービスを使用）
  static Future<List<Map<String, dynamic>>> searchNearbyPlaces({
    required LatLng location,
    required String type, // restaurant, tourist_attraction, etc.
    double radius = 5000, // 5km
  }) async {
    // 実装例：Google Places APIを使用する場合
    // 現在はダミーデータを返す
    return [
      {
        'name': 'サンプル レストラン',
        'type': 'restaurant',
        'rating': 4.5,
        'location': LatLng(location.latitude + 0.001, location.longitude + 0.001),
        'address': 'サンプル住所',
        'photoUrl': '',
      },
      {
        'name': 'サンプル 観光地',
        'type': 'tourist_attraction',
        'rating': 4.2,
        'location': LatLng(location.latitude - 0.001, location.longitude - 0.001),
        'address': 'サンプル住所2',
        'photoUrl': '',
      },
    ];
  }

  // ルート計算（実際のAPIでは外部サービスを使用）
  static Future<List<LatLng>?> calculateRoute(LatLng start, LatLng end) async {
    // 実装例：Google Directions APIを使用する場合
    // 現在は直線のダミールートを返す
    return [
      start,
      LatLng(
        (start.latitude + end.latitude) / 2,
        (start.longitude + end.longitude) / 2,
      ),
      end,
    ];
  }

  // カスタムマーカーアイコンを作成
  static Future<BitmapDescriptor> createCustomMarkerIcon({
    required String assetPath,
    int width = 100,
    int height = 100,
  }) async {
    try {
      return await BitmapDescriptor.asset(
        ImageConfiguration(size: Size(width.toDouble(), height.toDouble())),
        assetPath,
      );
    } catch (e) {
      print('Create Custom Marker Icon Error: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }
}