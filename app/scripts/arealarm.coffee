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

  ###*
   * Set radius of area
   * @param {number} radius Radius of area
  ###
  @setRadius = (radius) ->
    _radius = radius

  ###*
   * Start watch position
   * @param {number} watchingTime Watching time(time to end)
  ###
  @start = (watchingTime) ->
    console.log 'Start watching'
    _status = 'watching'
    timeoutWaitEnd = $timeout( ->
      console.log 'end time!!!'
      stopWatchPosition()
    , watchingTime)

    _watch()
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
  _watch = ->
    return if _status isnt 'watching'
    mapService.calcDistanceLocation()
      .then((distance) ->
        console.log '■Location from Phonegap, distance: ', distance

        if distance < _radius
          _onInArea()
        else
          nextTime = _calcNextTimeByDistance distance
          timeoutWatch = $timeout(
            -> watch(),
          nextTime)
      )

  ###*
   * Calculate next time to watch may location from distance
  ###
  _calcNextTimeByDistance = (distance) ->
    # return　[msec] if [m] > [m]
    return 60000 if distance > 3000
    return 30000 if distance > 1500
    return 20000 if distance > 1000
    return 10000 if distance > 500
    return 5000

  _self = @

  ###*
   * In area, alarm
  ###
  _onInArea = ->
    return if _status isnt 'watching'
    _status = 'alarming'
    
    console.log window.plugin.notification
    console.log window.plugin.notification.local
    console.log window.plugin.notification.local.promptForPermission
    
    window.plugin.notification.local.onadd = (id, state, json) ->
      console.log 'onadd: ', id, state, json


    window.plugin.notification.local.ontrigger = (id, state, json) ->
      console.log 'ontrigger: ', id, state, json

    window.plugin.notification.local.onclick = (id, state, json) ->
      console.log 'onclick: ', id, state, json
      if id is '1'
        _self.stop()
        # _self.wait()

    window.plugin.notification.local.add({
        id:      1
        title:   'In area'
        message: 'Click to stop notification'
        autoCancel: true
        # repeat:  'weekly',
        # date:    new Date().getTime()
    })

    # window.plugin.notification.local.hasPermission((granted) ->
      # console.log('Permission has been granted: ' + granted)
    # )
      
    # window.plugin.notification.local.promptForPermission()
    # return

    vibrateFlag = true
    repeatVibrate = ->
      console.log 'repeatVibrate'
      return if not vibrateFlag
      navigator.vibrate 800
      timeoutVibrate = $timeout repeatVibrate, 1600
    repeatVibrate()

  return @