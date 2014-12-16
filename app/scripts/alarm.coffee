'use strict'

angular.module('AREAlarm')


.directive 'alarmselect', ->
  return {
    restrict: 'E'
    replace: true
    templateUrl: 'templates/alarm.html'
    controller: ['$scope', ($scope) ->

      $scope.onClickDemo = ->
        console.log 'onClickDemo'
        console.log navigator
        # console.log navigator.vibrate
        # navigator.vibrate 100

      return
    ]
  }