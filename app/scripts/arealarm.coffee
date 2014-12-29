'use strict'

angular.module('AREAlarm')

.directive 'cover', ($ionicPlatform, timeService, positionWatcher) ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'templates/cover.html'
    controller: ['$scope', ($scope) ->

      $scope.status = 'stopping'
      $scope.$watch('status', ->
        console.log 'status---------------', $scope.status
      )

      positionWatcher.setScopeStatus((status) ->
        $scope.status = status
      )


      $ionicPlatform.ready ->
        window.plugin.notification.local.onclick = (id, state, json) ->
          console.log 'onclick: ', id, state, json
          if id is '1'
            _restartWatching()

      _waitWatching = ->
        waitTime = timeService.calcTime2start $scope.setting.time
        positionWatcher.wait waitTime

      _restartWatching = ->
        positionWatcher.stop()
        _waitWatching()

      $scope.onClickStopWait = ->
        console.log 'onClickStopWait'
        $scope.setting.power = false

      $scope.onClickStopWatch = ->
        console.log 'onClickStopWatch'
        $scope.setting.power = false

      $scope.onClickStopAlarm = ->
        _restartWatching()

      return
    ]
  }



.service 'positionWatcher', ($timeout, mapService) ->
  timeoutWaitStart = timeoutWaitEnd = timeoutWatch = timeoutVibrate = 0
  vibrateFlag = false
  _radius = 0
  _status = 'stopping'


  _setStatus = ->
    return

  @setScopeStatus = (setStatus) ->
    _setStatus = (status) ->
      _status = status
      setStatus status
    @

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
    _setStatus 'watching'
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
    _setStatus 'stoping'
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
    _setStatus 'waiting'
    console.log 'waitWatchPosition'
    now = new Date().getTime()
    date = new Date(now + waitTime)
    window.plugin.notification.local.add({
        id: 2
        title: 'Start time'
        autoCancel: true
        date: date
    })

    window.plugin.notification.local.onclick = (id, state, json) ->
      console.log 'onclick: ', id, state, json
      if id is '2'
        navigator.vibrate 5000
    # timeoutWaitStart = $timeout( =>
    #   console.log 'start time!!!'
    #   @.start()
    # , waitTime)
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
    _setStatus 'alarming'
    # console.log window.plugin.notification
    # console.log window.plugin.notification.local
    # console.log window.plugin.notification.local.promptForPermission
    
    window.plugin.notification.local.onadd = (id, state, json) ->
      console.log 'onadd: ', id, state, json


    window.plugin.notification.local.ontrigger = (id, state, json) ->
      console.log 'ontrigger: ', id, state, json

    # window.plugin.notification.local.onclick = (id, state, json) ->
    #   console.log 'onclick: ', id, state, json
    #   if id is '1'
    #     _self.stop()
        # _self.wait()

    window.plugin.notification.local.add({
        id: 1
        title: 'In area'
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