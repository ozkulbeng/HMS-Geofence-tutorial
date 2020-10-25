import 'package:huawei_map/components/components.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:huawei_site/model/coordinate.dart';
import 'package:huawei_site/model/location_type.dart';
import 'package:huawei_site/model/nearby_search_request.dart';
import 'package:huawei_site/model/nearby_search_response.dart';
import 'package:huawei_site/model/site.dart';
import 'package:huawei_site/search_service.dart';


nearbySearch(LatLng currentLocation, String searchText) async {
  Set<Marker> markers = {};
  SearchService searchService = SearchService();
  NearbySearchRequest request = new NearbySearchRequest();
  request.query = searchText;
  request.language = "en";
  request.location =
      Coordinate(lat: currentLocation.lat, lng: currentLocation.lng);
  request.radius = 2000;
  request.pageIndex = 1;
  request.pageSize = 5;
  request.poiType = LocationType.ADDRESS;
  NearbySearchResponse response = await searchService.nearbySearch(request);
  for (int i = 0; i < response.sites.length; i++) {
    Site site = response.sites[i];
    print(site);
    Marker marker = Marker(
      markerId: MarkerId(site.siteId.toString()),
      position: LatLng(site.location.lat, site.location.lng),
      infoWindow: InfoWindow(title: site.name, snippet: site.formatAddress),
    );
    markers.add(marker);
  }
  return markers;
}
