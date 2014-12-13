'use strict'

###*
 # @ngdoc function
 # @name arearamApp.directive:timepicker
 # @description
 # # timepicker
 # Directive of the arearamApp
###
angular.module('AREAlarm')

.directive 'timeselect', ->
  return {
    restrict: 'E'
    replace: true
    scope: true
    templateUrl: 'templates/time.html'
    controller: ['$scope', ($scope) ->
      if not $scope.setting?
        $scope.setting = {}

      if not $scope.setting.time?
        $scope.setting.time = {}

      if not $scope.setting.time.days?
        $scope.setting.time.days = [false, true, true, true, true, true, false]

      if not $scope.setting.time.start?
        $scope.setting.time.start = '8:00'

      if not $scope.setting.time.end?
        $scope.setting.time.end = '9:00'


      $scope.isDayTure = (day) ->
        if day
          return 'button-clear button-positive'
        else
          return 'button-stable'
    ]
    # link: (scope, element, attrs) ->
      # return
  }


.directive 'timepicker', ->
  return {
    templateUrl: 'templates/timepicker.html',
    link: (scope, element, attrs) ->
      return
  }