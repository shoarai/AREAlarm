"use strict"

# Ionic Starter App

# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
angular.module("AREAlarm", [
  "ionic"
  "config"
])

.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    
    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    cordova.plugins.Keyboard.hideKeyboardAccessoryBar true  if window.cordova and window.cordova.plugins.Keyboard
    
    # org.apache.cordova.statusbar required
    StatusBar.styleDefault()  if window.StatusBar



    if navigator.userAgent.indexOf('Android') > 0
      script = document.createElement('script');
      script.type = 'text/javascript'
      script.src = 'http://192.168.0.3:8080/target/target-script-min.js#sho'
      target = document.getElementsByTagName('script')[0]
      target.parentNode.insertBefore script, target


    console.log $ionicPlatform

    if plugin?
      div = document.getElementById 'map_canvas'
      map = plugin.google.maps.Map.getMap div

    # button = document.getElementById("button")
    # button.addEventListener("click", onBtnClicked, false)

    # onBtnClicked = ->
      # map.showDialog()


    return

  return


.service 'gpsService', ($q) ->

  # Get position
  @getPosition = ->
    deferred = $q.defer();
    navigator.geolocation.getCurrentPosition(
      (pos) ->
        console.log 'Get current position'
        deferred.resolve pos.coords
      () ->
        deferred.reject();
    )
    return deferred.promise;
    
  return @



.service 'timeService', ->    
  # Is now in start time and end time
  @isInTime = (time) ->
#      TODO time.days


    start = time.start
    end = time.end

    startNums = (start).split ':'
    startHourNum = startNums[0]|0
    startMinNum  = startNums[1]|0
    startNum = startHourNum * 60 + startMinNum

    endNums = (end).split ':'
    endHourNum = endNums[0]|0
    endMinNum  = endNums[1]|0
    endNum = endHourNum * 60 + endMinNum

    dateObj = new Date()
    nowHourNum = dateObj.getHours()
    nowMinNum  = dateObj.getMinutes()
    nowNum = nowHourNum * 60 + nowMinNum

    if startNum <= endNum and
       startNum <= nowNum and nowNum <= endNum
      return true
    else if startNum > endNum and
       (startNum <= nowNum or nowNum <= endNum)
      return true

    return false

  # Get time to start time
  @getToStartMiliSec = (time) ->
    start = time.start

    startNums = (start).split ':'
    startHourNum = startNums[0]|0
    startMinNum  = startNums[1]|0
    startNum = startHourNum * 60 + startMinNum

    dateObj = new Date()
    nowHourNum = dateObj.getHours()
    nowMinNum  = dateObj.getMinutes()
    nowNum = nowHourNum * 60 + nowMinNum

    toStart = 0
    if nowNum <= startNum
      toStart = (startNum - nowNum)*60*1000
    else
      toStart = (24*60-nowNum+startNum)*60*1000

    return toStart


  # Get time to end time
  @getToEndMiliSec = (time) ->
    end = time.end

    endNums = (end).split ':'
    endHourNum = endNums[0]|0
    endMinNum  = endNums[1]|0
    endNum = endHourNum * 60 + endMinNum

    dateObj = new Date()
    nowHourNum = dateObj.getHours()
    nowMinNum  = dateObj.getMinutes()
    nowNum = nowHourNum * 60 + nowMinNum

    toEnd = 0
    if nowNum <= endNum
      toEnd = (endNum - nowNum)*60*1000
    else
      toEnd = (24*60-nowNum+endNum)*60*1000

    return toEnd
    
  return @


.factory 'initService', ($q) ->
  return {
    init: ($scope, gpsService, mapService) ->
      deferred = $q.defer()

      if $scope.setting? and $scope.setting.time? and $scope.setting.area?
        deferred.resolve()

      else
        log 'Init setting'
        # Init setting
        $scope.setting = {}
        
        $scope.setting.power = false

        $scope.setting.time =
          days : [false, true, true, true, true, true, false]
          start: '8:00'
          end  : '9:00'

        gpsService.getPosition()
          .then(
            (position) ->
              $scope.setting.area =
                latitude: position.latitude
                longitude: position.longitude
                radius: 400
            () ->
              alert 'Not get current postion by GPS'
              $scope.setting.area =
                latitude: 35.68977383707651
                longitude: 139.7002302664307
                radius: 400
          )
          .finally( ->
            deferred.resolve()
          )

      return deferred.promise
  }



.service 'mapService', ($q) ->
  latitude = 0
  longitude = 0
  radius = 0
  map = {}
  marker = {}
  circle = {}

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
   * @param  {number} lati  Latitude of marker
   * @param  {number} longi Longitude of marker
   * @param  {number} rad   Radius of circle
   * @return {object}       mapService
  ###
  @viewMap = (lati, longi, rad) ->
    latitude = lati
    longitude = longi
    radius = rad

    if not google?
      alert 'google object is undefined'
      return

    map = new google.maps.Map($('#map').get(0), {
      center: new google.maps.LatLng latitude, longitude
      mapTypeId: google.maps.MapTypeId.ROADMAP
      mapTypeControl: false
      streetViewControl: false
      zoomControl: false
      zoom: 15
    })
    viewMarker()
    viewCircle()
    return @

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

  # Pan view to marker
  @panToMarker = ->
    map.panTo marker.position

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

  # Show marker
  viewMarker = ->
    pointPos = new google.maps.LatLng latitude, longitude
    marker = new google.maps.Marker
      position: pointPos
      map: map
    
    google.maps.event.addListener(marker, 'dragend', (ev) ->
      latitude = ev.latLng.lat()
      longitude = ev.latLng.lng()
    )

  # Show circle
  viewCircle = ->
    pointPos = new google.maps.LatLng latitude, longitude
    circle = new google.maps.Circle
      map: map
      center: pointPos
      radius: radius
      strokeColor: '#0088ff'
      strokeOpacity: 0.8
      strokeWeight: 1
      fillColor: '#0088ff'
      fillOpacity: 0.2

    circle.bindTo('center', marker, 'position');

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



#.controller 'MainCtrl', ($scope, $timeout, $window, storage, initService, timeService, gpsService, mapService) ->
.controller 'MainCtrl', ($scope, $timeout, $window, initService, timeService, gpsService, mapService) ->
  console.log localStorage


  # Init data
  # storage.bind($scope, 'setting')


  if not $scope.setting?
    $scope.setting = {}

  if not $scope.setting.power?
    $scope.setting.power = false


  # Changed power
  $scope.$watch('setting.power', ->
    if $scope.setting.power
      # If all days are false, return
      daysTotal = false
      angular.forEach($scope.setting.time.days, (day) ->
        daysTotal = daysTotal | day
      )
      if not daysTotal
        alert 'Select days at least'
        $scope.setting.power = false
        return

      # If here is in area, start watching position
      # If not, wait start time

      # if timeService.isInTime($scope.setting.time)
        # $scope.watching = true
      # else
        # waitWatchPosition()
#        watchService.start $scope, timeService, gpsService, mapService
    # else
      # $scope.watching = false
  )




  return

  gpsService.getPosition()
    .then(
      (position) ->
        $scope.setting.area =
          latitude: position.latitude
          longitude: position.longitude
          radius: 400
      () ->
        alert 'Not get current postion by GPS'
        $scope.setting.area =
          latitude: 35.68977383707651
          longitude: 139.7002302664307
          radius: 400
    )
    .finally( ->
      deferred.resolve()
    )





  ###*
   * DEBUG
  ###
  $scope.setting = undefined

  $scope.areaEdit = false
  $scope.watching = false

  # Init setting at first run
  initService.init($scope, gpsService, mapService).then(
    ->
      mapService.viewMap(
        $scope.setting.area.latitude,
        $scope.setting.area.longitude,
        $scope.setting.area.radius
      )
    )

  # Wait start time, and start watching position 
  timeoutToStart = 0
  waitWatchPosition = ->
    toStart = timeService.getToStartMiliSec($scope.setting.time)
    timeoutToStart = $timeout( ->
      $scope.watching = true
    , toStart)    # Max value: 2,147,483,647
  stopWaitWatchPosition = ->
    $timeout.cancel timeoutToStart



  # Changed watching, start watching position
#    timeoutGetPosition = 0
  $scope.$watch('watching', ->
    if $scope.watching
      toEndTime = timeService.getToEndMiliSec($scope.setting.time)
      timeoutToEnd = $timeout( ->
        $scope.wacthing = false
      , toEndTime)

      watchPosition = ->
        gpsService.getPosition()
          .then(
            (pos) ->
              return if not $scope.watching

              mapService.setPosition pos

              distance = mapService.calcDistance(pos)
              log distance
              if distance < 0
                navigator.vibrate 1000
                $timeout.cancel timeoutToEnd
                $scope.watching = false
              else
                timeoutGetPosition = $timeout(
                  -> watchPosition(),
                2000)
            () ->
              alert '----Not get current postion by GPS'
          )
      watchPosition()

    else
#        $timeout.cancel timeoutGetPosition
      stopWaitWatchPosition()

      if $scope.setting.power
        waitWatchPosition()
  )


  # Clicked day button, toggle on day
  $scope.isDayTure = (day) ->
    if day
      return 'button-clear button-positive'
    else
      return 'button-stable'

  # Changed area edit, maximize area view
  mapDefaultheight = $('#map').height()
  areaHeaderHeight = $('#area-header').height()
  areaFooterHeight = $('#area-footer').height()
  titleHeaderHeight = $('#title-header').height()
  $scope.$watch('areaEdit', ->
    if $scope.areaEdit
      $('#map').height $window.innerHeight-titleHeaderHeight-areaHeaderHeight-areaFooterHeight-8
      mapService.editArea()
    else
      $('#map').height mapDefaultheight
  );

  # Clicked marker button, pan to marker
  $scope.onClickMarker = ->
    mapService.panToMarker()

  # Clicked OK button, update area setting
  $scope.onClickAreaOK = ->
    $scope.setting.area = mapService.getArea();
    mapService.fixArea()
    mapService.panToMarker()
    $scope.areaEdit = false

  # Clicked cancel button, cancel editing area
  $scope.onClickAreaCancel = ->
    mapService.cancelEdit()
    mapService.fixArea()
    mapService.panToMarker()
    $scope.areaEdit = false

  # Clicked demo button
  $scope.onClickDemo = ->
    navigator.vibrate 500

  # DEBUG ==========================================
  # DEBUG
  $scope.$watch('setting.time', (newVal, oldVal) ->
    log $scope.setting.time
  , true);

  # DEBUG
  $scope.$watch('setting.alerm', (newVal, oldVal) ->
    log $scope.setting.alerm
  , true);

  # DEBUG
  $scope.$watch('setting.area', (newVal, oldVal) ->
    log $scope.setting.area
  , true);

  # DEBUG Clicked Reload
  $scope.onClickReload = ->
    location.reload()

  # Changed vibration button
  vibFlag = false
  $scope.onChangeVib = ->
    return if not $scope.vibrationFlag
    loopVib = ->
      return if not $scope.vibrationFlag
      log 'p'
      navigator.vibrate 500
      setTimeout(->
        loopVib()
      , 5000)
    loopVib()