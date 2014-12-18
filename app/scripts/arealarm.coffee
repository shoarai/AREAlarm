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

  ###*
   * Start watch position
  ###
  @start = (watchingTime) ->
    console.log 'Start wathing'
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
    onInArea()

    return
    # TODO Get position

    # distance = mapService.calcDistance pos
    if distance < 0
      onInArea()
    else
      timeoutWatch = $timeout(
        -> watchPosition(),
      2000)

  onInArea = ->
    vibrateFlag = true
    repeatVibrate = ->
      console.log 'repeatVibrate'
      return if not vibrateFlag
      navigator.vibrate 800
      timeoutVibrate = $timeout repeatVibrate, 1600
    repeatVibrate()

  return @