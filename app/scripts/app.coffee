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
.controller 'MainCtrl', ($scope, $window, storage, timeService, positionWatcher) ->
  # DEBUG
  # localStorage.clear()


  $scope.areaEditing = false

  $scope.$watch 'areaEditing', ->
    console.log '-----------Watch edit: ', $scope.areaEditing
  , true

  
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
    console.log $scope.areaEditing
    
    if $scope.setting.power
      # If all days are false, return
      daysTotal = false
      angular.forEach($scope.setting.time.days, (day) ->
        daysTotal = daysTotal | day
      )
      if not daysTotal
        $scope.setting.power = false
        navigator.notification.alert 'Select day at least', null, 'Error'
        return

      positionWatcher.setRadius $scope.setting.area.radius

      # If here is in area, start watching position
      # If not, wait start time
      if timeService.isInTime $scope.setting.time
        toEnd = timeService.calcTime2end $scope.setting.time
        positionWatcher.start toEnd
      else
        toStart = timeService.calcTime2start $scope.setting.time
        console.log 'not isInTime, toStart: ', toStart
        positionWatcher.wait toStart
    else
      positionWatcher.stop()
  )
