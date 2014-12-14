'use strict'

angular.module('AREAlarm')


.directive 'areaselect', ($ionicPlatform, mapService) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'templates/area.html'
    controller: ['$scope', ($scope) ->

      $ionicPlatform.ready ->
        console.log '$ionicPlatform.ready'

        # DEBUG
        # $scope.setting.area =
        #   latitude: 35.68977383707651
        #   longitude: 139.7002302664307
        #   radius: 400


        if $scope.setting? and $scope.setting.area? and $scope.setting.area.latitude?
          console.log 'Settings area: ', $scope.setting.area
          mapService.showMap 'map_canvas', $scope.setting.area.latitude, $scope.setting.area.longitude, $scope.setting.area.radius
            .then(
              ->
                onReadyMap()
            )
        
        else
          console.log 'Init settings'
          mapService.showMap 'map_canvas'
            .then(
              ->
                onReadyMap()
                mapService.getMyLocation()
                  .then(
                    (position) ->
                      $scope.setting.area =
                        latitude: position.latitude
                        longitude: position.longitude
                        radius: 400
                    ->
                      alert 'Not get current postion by GPS'
                      $scope.setting.area =
                        latitude: 35.68977383707651
                        longitude: 139.7002302664307
                        radius: 400
                  )
                  .finally(
                    ->
                      mapService.showArea $scope.setting.area.latitude, $scope.setting.area.longitude, $scope.setting.area.radius
                        .then(
                          ->
                            console.log 'showed Area'
                            mapService.panToArea()
                        )
                  )
            )


      onReadyMap = ->
        console.log 'onReadyMap'

        $scope.onClickLocate = ->
          console.log 'onClickLocate'
          mapService.panToMyLocation()

        $scope.onClickMarker = ->
          console.log 'onClickMarker'
          mapService.panToArea()

      return
    ]
    # link: (scope, element, attrs) ->
      # return
  }



.service 'mapService', ($q) ->
  latitude = longitude = radius = 0
  _map = _marker = _circle = {}

  ###*
   * Get area
  ###
  @getArea = ->
    return {
      latitude: latitude
      longitude: longitude
      radius: circle.radius
    }

  ###*
   * Show map
   * @param  {string} id    Element id
   * @param  {number} lati  Latitude of marker
   * @param  {number} longi Longitude of marker
   * @param  {number} rad   Radius of circle
   * @return {object}       mapService
  ###
  @showMap = (id, lati, longi, rad) ->
    deferred = $q.defer()

    if not plugin?
      console.log 'Object of plugin is undefined'
      deferred.reject()
      return deferred.promise

    mapDiv = document.getElementById id
    if lati?
      console.log 'def', lati
      _map = plugin.google.maps.Map.getMap mapDiv, {
          camera:
            latLng: new plugin.google.maps.LatLng lati, longi
            zoom: 13
        }
      _map.clear()
      _map.on plugin.google.maps.event.MAP_READY,
        (map) =>
          console.log 'onMapReady'
          @.showArea lati, longi, rad
          deferred.resolve()
    else
      console.log 'nondef'
      _map = plugin.google.maps.Map.getMap mapDiv
      _map.clear()
      _map.on plugin.google.maps.event.MAP_READY,
        (map) ->
          console.log 'onMapReady'
          deferred.resolve()

    return deferred.promise


  ###*
   * Show area of circle
   * @param  {number} lati  Latitude of center
   * @param  {number} longi Longitude of center
   * @param  {number} rad   Radius of circle
  ###
  @showArea = (latitude, longitude, radius) ->
    console.log 'showArea'
    deferred = $q.defer()
    $q.all([
      showMarker latitude, longitude
      showCircle latitude, longitude, radius
    ]).then(
      ->
        _marker.addEventListener plugin.google.maps.event.MARKER_DRAG_END,
          (marker) ->
            console.log 'Dragend marker:', marker
            marker.getPosition(
              (latLng) ->
                _circle.setCenter latLng
            )

        deferred.resolve()
    )
    return deferred.promise

  ###*
   * Get my position
  ###
  @getMyLocation = ->
    deferred = $q.defer()
    _map.getMyLocation(
      (location) ->
        console.log 'Get position', location.latLng.lat, location.latLng.lng
        deferred.resolve({
          latitude: location.latLng.lat
          longitude: location.latLng.lng
        })
      (msg) ->
        deferred.reject(msg)
    )
    return deferred.promise
 
  ###*
   * Pan to my location
  ###
  @panToMyLocation = ->
    @.getMyLocation()
      .then(
        (position) ->
          _map.animateCamera {
            'target': new plugin.google.maps.LatLng position.latitude, position.longitude
            'zoom': 13
            'duration': 1000
          }
      )
    return

  ###*
   * Pan to area
  ###
  @panToArea = ->
    _marker.getPosition(
      (latLng) ->
        console.log 'Pan to marker: ', latLng.lat, latLng.lng
        _map.animateCamera {
          'target': new plugin.google.maps.LatLng latLng.lat, latLng.lng
          'zoom': 13
          'duration': 1000
        }
    )
    # map.panTo marker.position

  ###*
   * Show marker
  ###
  showMarker = (latitude, longitude) ->
    console.log 'showMarker: ', latitude, longitude
    deferred = $q.defer()
    _map.addMarker {
      position: new plugin.google.maps.LatLng latitude, longitude
      draggable: true
    }, (marker) ->
      console.log 'showedMarker: ', marker
      _marker = marker
      deferred.resolve _marker
    return deferred.promise

    # pointPos = new google.maps.LatLng latitude, longitude
    # marker = new google.maps.Marker
    #   position: pointPos
    #   map: map
    
    # google.maps.event.addListener(marker, 'dragend', (ev) ->
    #   latitude = ev.latLng.lat()
    #   longitude = ev.latLng.lng()
    # )
     
  # Show circle
  showCircle = (latitude, longitude, radius) ->
    console.log 'showCircle: ', latitude, longitude, radius
    deferred = $q.defer()
    _map.addCircle({
      center: new plugin.google.maps.LatLng latitude, longitude
      radius: radius,
      strokeColor : '#AA00FF',
      strokeWidth: 5,
      fillColor : '#880000'
    }, (circle) ->
      console.log 'showedCircle: ', circle
      _circle = circle
      deferred.resolve _circle
    )
    return deferred.promise

    # pointPos = new google.maps.LatLng latitude, longitude
    # circle = new google.maps.Circle
    #   map: map
    #   center: pointPos
    #   radius: radius
    #   strokeColor: '#0088ff'
    #   strokeOpacity: 0.8
    #   strokeWeight: 1
    #   fillColor: '#0088ff'
    #   fillOpacity: 0.2

    # circle.bindTo('center', marker, 'position');

  # Calcrate distance from area to here
  @calcDistance = (pos) ->
    distance = calcDistance pos.latitude, pos.longitude, latitude, longitude
    return distance-radius

  # Set position
  @setPosition = (pos) ->
    pointPos = new google.maps.LatLng pos.latitude, pos.longitude
    marker = new google.maps.Marker
      position: pointPos
      map: map
      icon:
        path: google.maps.SymbolPath.CIRCLE
        scale: 10
    return null



  # Area editable
  tmpLatitude = tmpLongitude = tmpRadius = false
  @editArea = ->
    tmpLatitude = latitude
    tmpLongitude = longitude
    tmpRadius = radius

    marker.setDraggable true
    circle.setEditable true
    google.maps.event.trigger map, 'resize'

  # Area not editable
  @fixArea = ->
    marker.setDraggable false
    circle.setEditable false
    google.maps.event.trigger map, 'resize'

 # Cancel editing area
  @cancelEdit = ->
    latitude = tmpLatitude
    longitude = tmpLongitude
    radius = tmpRadius
    marker.setPosition new google.maps.LatLng(latitude, longitude)
    circle.setRadius radius


  # Calculate distance of two point
  # http://emiyou3-tools.appspot.com/geocoding/distance.html
  calcDistance = (lat1, lon1, lat2, lon2) ->
    # ラジアンに変換
    a_lat = lat1 * Math.PI / 180;
    a_lon = lon1 * Math.PI / 180;
    b_lat = lat2 * Math.PI / 180;
    b_lon = lon2 * Math.PI / 180;

    # 緯度の平均、緯度間の差、経度間の差
    latave = (a_lat + b_lat) / 2;
    latidiff = a_lat - b_lat;
    longdiff = a_lon - b_lon;

    # 子午線曲率半径
    # 半径を6335439m、離心率を0.006694で設定してます
    meridian = 6335439 / Math.sqrt(Math.pow(1 - 0.006694 * Math.sin(latave) * Math.sin(latave), 3));    

    # 卯酉線曲率半径
    # 半径を6378137m、離心率を0.006694で設定してます
    primevertical = 6378137 / Math.sqrt(1 - 0.006694 * Math.sin(latave) * Math.sin(latave));     

   # Hubenyの簡易式
    x = meridian * latidiff;
    y = primevertical * Math.cos(latave) * longdiff;

    return Math.sqrt(Math.pow(x,2) + Math.pow(y,2));

  return @