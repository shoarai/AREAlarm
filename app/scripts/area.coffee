'use strict'

angular.module('AREAlarm')

.directive('areaselect', ->
  return {
    restrict: 'E',
    replace: true,
    templateUrl: 'templates/area.html',
    link: (scope, element, attrs) ->
      return
  }
)