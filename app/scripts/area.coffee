'use strict'

angular.module('AREAlarm')


.directive 'areaselect', ($ionicPlatform, $window, mapService) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'templates/area.html'
    scope: {
      area: '='
      editing: '='
    }
    controller: ['$scope', ($scope) ->

      $ionicPlatform.ready ->
        console.log '$ionicPlatform.ready'

        # DEBUG
        # $scope.area =
        #   latitude: 35.68977383707651
        #   longitude: 139.7002302664307
        #   radius: 400

        if $scope.area? and $scope.area.latitude?
          console.log 'Settings area: ', $scope.area
          mapService.showMap 'map-canvas', $scope.area
            .then(
              ->
                onReadyMap()
            )
        
        else
          console.log 'Init settings'
          mapService.showMap 'map-canvas'
            .then(
              ->
                mapService.getMyLocation()
                  .then(
                    (position) ->
                      console.log 'Init settings!!'
                      $scope.area =
                        latitude: position.latitude
                        longitude: position.longitude
                        radius: 400
                    ->
                      alert 'Not get current postion by GPS'
                      $scope.area =
                        latitude: 35.68977383707651
                        longitude: 139.7002302664307
                        radius: 400
                  )
                  .finally(
                    ->
                      onReadyMap()
                      mapService.showArea $scope.area
                        .then(
                          ->
                            console.log 'showed Area'
                            mapService.panToArea()
                        )
                  )
            )


      onReadyMap = ->
        console.log 'onReadyMap'
        areaBeforeEdit = $scope.area
        $scope.radius = $scope.area.radius
        $scope.editing = false

        $scope.onClickLocate = ->
          console.log 'onClickLocate'
          mapService.panToMyLocation()

        $scope.onClickMarker = ->
          console.log 'onClickMarker'
          mapService.panToArea()

        $scope.onChangeRadius = (radius) ->
          console.log 'onClickRadius'
          mapService.setAreaRadius radius

        $scope.onClickEdit = ->
          console.log 'onClickEdit'
          mapService.editArea()
          areaBeforeEdit = $scope.area
          $scope.editing = true

        $scope.onkeydownSearch = (event) ->
          console.log 'onkeydownSearch: ', event.target.value
          if event.which is 13
            console.log 'enter key'
            event.target.blur()
            value = event.target.value
            mapService.searchPosition(value)

        $scope.onClickSetMarker = ->
          console.log 'onClickSetMarker'
          mapService.setMarkerInCenter()

        finishEdit = ->
          mapService.finishEditArea()
          $scope.editing = false

        $scope.onClickOK = ->
          console.log 'onClickOK'
          finishEdit()
          $scope.area = mapService.getArea()
          mapService.panToArea()

        $scope.onClickCancel = ->
          console.log 'onClickCancel'
          finishEdit()
          $scope.radius = $scope.area.radius
          mapService.showArea areaBeforeEdit
            .then(
              ->
                mapService.panToArea()
            )

      return
    ]
    link: (scope, element, attrs) ->

      # defaultHeight = element.children()[0].style.height
      defaultHeight = 300
      mapElement = element.children()[0]

      scope.$watch('editing', (newValue) ->
        if newValue
          height = $window.innerHeight - 140
          mapElement.style.height = height+'px'
        else
          mapElement.style.height = defaultHeight+'px'
      )

      return
  }



.service 'mapService', ($q) ->
  latitude = longitude = radius = 0
  _map = _marker = _circle = {}

  ###*
   * Show map
   * @param  {string} id    Element id
   * @param  {object} area  area
  ###
  @showMap = (id, area) ->
    deferred = $q.defer()

    if not plugin?
      console.log 'Object of plugin is undefined'
      deferred.reject()
      return deferred.promise

    mapDiv = document.getElementById id
    if area?
      _map = plugin.google.maps.Map.getMap mapDiv, {
          camera:
            latLng: new plugin.google.maps.LatLng area.latitude, area.longitude
            zoom: 13
        }
      # Remove all marker
      _map.clear()
      _map.on plugin.google.maps.event.MAP_READY,
        (map) =>
          console.log 'onMapReady, map: ', map
          @.showArea area
          deferred.resolve()
    else
      _map = plugin.google.maps.Map.getMap mapDiv
      _map.clear()
      _map.on plugin.google.maps.event.MAP_READY,
        (map) ->
          console.log 'onMapReady'
          deferred.resolve()

    return deferred.promise


  ###*
   * Show area of circle
   * @param  {object} area  area
  ###
  @showArea = (area) ->
    console.log 'showArea'
    deferred = $q.defer()

    if _marker.remove?
      _marker.remove()
    if _circle.remove?
      _circle.remove()

    $q.all([
      showMarker area.latitude, area.longitude
      showCircle area
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
          target: new plugin.google.maps.LatLng latLng.lat, latLng.lng
          zoom: 13
          duration: 1000
        }
    )
    # map.panTo marker.position

  ###*
   * Set radius of area
  ###
  @setAreaRadius = (radius) ->
    _circle.setRadius radius

  ###*
   * Get area
  ###
  @getArea = ->
    latLng = _circle.getCenter()
    console.log latLng
    return {
      latitude: latLng.lat
      longitude: latLng.lng
      radius: _circle.getRadius()
    }


    # return {
    #   latitude: latitude
    #   longitude: longitude
    #   radius: circle.radius
    # }


  ###*
   * Show marker
   * @private
  ###
  showMarker = (latitude, longitude) ->
    console.log 'showMarker: ', latitude, longitude
    deferred = $q.defer()
    _map.addMarker {
      position: new plugin.google.maps.LatLng latitude, longitude
      # draggable: true
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
     
  ###
   * Show Circle
   * @private
  ###
  showCircle = (area) ->
    console.log 'showCircle: ', area
    deferred = $q.defer()
    _map.addCircle({
      center: new plugin.google.maps.LatLng area.latitude, area.longitude
      radius: area.radius
      strokeColor : 'rgb(74, 135, 238)'
      strokeWidth: 5
      fillColor : 'rgb(67, 206, 230)'
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

  # Area editable
  @editArea = ->
    _marker.setDraggable true

    # tmpLatitude = latitude
    # tmpLongitude = longitude
    # tmpRadius = radius

    # marker.setDraggable true
    # circle.setEditable true
    # google.maps.event.trigger map, 'resize'

  # Area not editable
  @finishEditArea = ->
    _marker.setDraggable false

  #   marker.setDraggable false
  #   circle.setEditable false
  #   google.maps.event.trigger map, 'resize'

 # Cancel editing area
  # @cancelEdit = ->
  #   latitude = tmpLatitude
  #   longitude = tmpLongitude
  #   radius = tmpRadius
  #   marker.setPosition new google.maps.LatLng(latitude, longitude)
  #   circle.setRadius radius

  @searchPosition = (address) ->
    deferred = $q.defer()
    plugin.google.maps.Geocoder.geocode({address:address},
      (results) ->
        if results.length
          result = results[0];
          position = result.position; 

          _map.animateCamera {
            target: position
            zoom: 13
            duration: 1000
          }
        else
          alert 'Not found'
    )
    return deferred.promise

  @setMarkerInCenter = ->
    _map.getCameraPosition(
      (camera) ->
        latLng = camera.target
        _marker.setPosition latLng
        _circle.setCenter latLng

        # var buff = ["Current camera position:\n",
        #     "latitude:" + camera.target.lat,
        #     "longitude:" + camera.target.lng,
        #     "zoom:" + camera.zoom,
        #     "tilt:" + camera.tilt,
        #     "bearing:" + camera.bearing].join("\n");
        # alert(buff);
    )

  @calcDistanceLocation = ->
    deferred = $q.defer()
    window.navigator.geolocation.getCurrentPosition(
      (location) =>
        @.calcDistanceMarker location.coords.latitude, location.coords.longitude
          .then((distance) ->
            deferred.resolve distance
          )
      )
    return deferred.promise

  # Calculate ditance of position and marker
  @calcDistanceMarker = (latitude, longitude) ->
    deferred = $q.defer()
    _marker.getPosition( (latLng) ->
      distance = calcDistance latitude, longitude, latLng.lat, latLng.lng
      deferred.resolve distance
    )
    return deferred.promise;

  # Calculate distance of two positions
  # http://emiyou3-tools.appspot.com/geocoding/distance.html
  calcDistance = (lat1, lon1, lat2, lon2) ->
    # ラジアンに変換
    a_lat = lat1 * Math.PI / 180
    a_lon = lon1 * Math.PI / 180
    b_lat = lat2 * Math.PI / 180
    b_lon = lon2 * Math.PI / 180

    # 緯度の平均、緯度間の差、経度間の差
    latave = (a_lat + b_lat) / 2
    latidiff = a_lat - b_lat
    longdiff = a_lon - b_lon

    # 子午線曲率半径
    # 半径を6335439m、離心率を0.006694で設定してます
    meridian = 6335439 / Math.sqrt(Math.pow(1 - 0.006694 * Math.sin(latave) * Math.sin(latave), 3))

    # 卯酉線曲率半径
    # 半径を6378137m、離心率を0.006694で設定してます
    primevertical = 6378137 / Math.sqrt(1 - 0.006694 * Math.sin(latave) * Math.sin(latave))

   # Hubenyの簡易式
    x = meridian * latidiff;
    y = primevertical * Math.cos(latave) * longdiff

    return Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2))

  return @