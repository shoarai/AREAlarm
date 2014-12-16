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
        navigator.vibrate 100

      return
    ]
  }