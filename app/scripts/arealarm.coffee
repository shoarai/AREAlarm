'use strict'

angular.module('AREAlarm')

.directive 'cover', (timeService, positionWatcher) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'templates/cover.html'
    controller: ['$scope', ($scope) ->
      $scope.onClickStopWait = ->
        console.log 'onClickStopWait'
        $scope.setting.power = false

      $scope.onClickStopWatch = ->
        console.log 'onClickStopWatch'
        $scope.setting.power = false

      $scope.onClickStopAlarm = ->
        positionWatcher.stop()
        waitTime = timeService.calcTime2start $scope.setting.time
        positionWatcher.wait waitTime

      return
    ]
  }



.service 'positionWatcher', ($timeout, mapService) ->
  timeoutWaitStart = timeoutWaitEnd = timeoutWatch = timeoutVibrate = 0
  vibrateFlag = false
  _radius = 0
  _status = 'stopping'

  @setRadius = (radius) ->
    _radius = radius

  ###*
   * Start watch position
  ###
  @start = (watchingTime) ->
    console.log 'Start watching'
    _status = 'watching'
    timeoutWaitEnd = $timeout( ->
      console.log 'end time!!!'
      stopWatchPosition()
    , watchingTime)

    watch()
    return @

  ###*
   * Stop watch position
  ###
  @stop = ->
    _status = 'stoping'
    $timeout.cancel timeoutWaitStart
    $timeout.cancel timeoutWaitEnd
    $timeout.cancel timeoutWatch
    vibrateFlag = false
    if navigator.cancelVibration?
      navigator.cancelVibration()
    return @

  ###*
   * Wait watch position
  ###
  @wait = (waitTime) ->
    _status = 'waiting'
    console.log 'waitWatchPosition'
    timeoutWaitStart = $timeout( =>
      console.log 'start time!!!'
      @.start()
    , waitTime)
    return @

  ###*
   * Watch position
  ###
  watch = ->
    return if _status isnt 'watching'
    mapService.calcDistanceLocation()
      .then((distance) ->
        console.log '■Location from Phonegap, distance: ', distance

        if distance < _radius
          onInArea()
        else
          timeoutWatch = $timeout(
            -> watch(),
          5000)
      )


  onInArea = ->
    return if _status isnt 'watching'
    _status = 'alarming'
    vibrateFlag = true
    repeatVibrate = ->
      console.log 'repeatVibrate'
      return if not vibrateFlag
      navigator.vibrate 800
      timeoutVibrate = $timeout repeatVibrate, 1600
    repeatVibrate()

  return @