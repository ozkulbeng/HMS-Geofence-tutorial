import 'package:flutter/material.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:huawei_site/model/coordinate.dart';
import 'package:huawei_site/model/location_type.dart';
import 'package:huawei_site/model/nearby_search_request.dart';
import 'package:huawei_site/model/nearby_search_response.dart';
import 'package:huawei_site/search_service.dart';

void nearbySearch(LatLng currentLocation, String searchText) async
{
  SearchService searchService = SearchService();
  NearbySearchRequest request = new NearbySearchRequest();
  request.query = searchText;
  request.language = "en";
  request.location = Coordinate(lat: currentLocation.lat,
      lng: currentLocation.lng);
  request.radius = 2000;
  request.pageIndex = 1;
  request.pageSize = 5;
  request.poiType = LocationType.ADDRESS;
  NearbySearchResponse response = await searchService.nearbySearch(request);

}