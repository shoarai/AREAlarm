"use strict"

# Ionic Starter App

# angular.module is a global place for creating, registering and retrieving Angular modules
# 'starter' is the name of this angular module example (also set in a <body> attribute in index.html)
# the 2nd parameter is an array of 'requires'
angular.module("AREAlarm", [
  "ionic"
  "config"
  "angularLocalStorage"
])

.run ($ionicPlatform) ->
  $ionicPlatform.ready ->
    
    # Hide the accessory bar by default (remove this to show the accessory bar above the keyboard
    # for form inputs)
    cordova.plugins.Keyboard.hideKeyboardAccessoryBar true  if window.cordova and window.cordova.plugins.Keyboard
    
    # org.apache.cordova.statusbar required
    StatusBar.styleDefault()  if window.StatusBar

    # button = document.getElementById("button")
    # button.addEventListener("click", onBtnClicked, false)

    # onBtnClicked = ->
      # map.showDialog()

    return

  return


#.controller 'MainCtrl', ($scope, $timeout, $window, storage, initService, timeService, gpsService, mapService) ->
.controller 'MainCtrl', ($scope, $timeout, $window, storage, timeService) ->
  # DEBUG
  # localStorage.clear()
  
  console.log 'localStorage: ', localStorage

  # Init data
  storage.bind $scope, 'setting', {defaultValue:{}}

  if not $scope.setting.power?
    $scope.setting.power = false



  $scope.$watch 'setting', ->
    console.log 'Watch setting: ', $scope.setting
  , true


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
      if timeService.isInTime $scope.setting.time
        console.log 'isInTime'

        # $scope.watching = true
      else
        console.log 'not isInTime'

        # waitWatchPosition()
#        watchService.start $scope, timeService, gpsService, mapService
    # else
      # $scope.watching = false
  )




  return


  


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









.service 'timeService', ->    
  return {
    ###*
     * Is now in start time and end time
    ###
    isInTime: (time) ->
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

    ###*
     * Calculate time to start time
    ###
    calcTime2start: (time) ->
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

    ###*
     * Calculate time to end time
    ###
    calcTime2end: (time) ->
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
  }


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


