'use strict'

###*
 # @ngdoc function
 # @name arearamApp.directive:timepicker
 # @description
 # # timepicker
 # Directive of the arearamApp
###
angular.module('AREAlarm')

.directive('timeselect', ->
  return {
    restrict: 'E',
    replace: true,
    templateUrl: 'templates/time.html',
    link: (scope, element, attrs) ->
      return
  }
)

.directive('timepicker', ->
  return {
#    restrict: 'E',
#    replace: true,
    templateUrl: 'templates/timepicker.html',
    link: (scope, element, attrs) ->
      return
  }
)