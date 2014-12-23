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
    scope: {
      time: '=time'
    }
    templateUrl: 'templates/time.html'
    controller: ['$scope', ($scope) ->
      if not $scope.time?
        $scope.time = {}

      if not $scope.time.days?
        $scope.time.days = [false, true, true, true, true, true, false]

      if not $scope.time.start?
        $scope.time.start = '8:00'

      if not $scope.time.end?
        $scope.time.end = '9:00'


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
    templateUrl: 'templates/timepicker.html'
  }


.service 'timeService', ->    
  return {
    ###*
     * Is now in start time and end time
    ###
    isInTime: (time) ->
      start = time.start
      end = time.end

      startNums = (start).split ':'
      startHourNum = startNums[0]|0
      startMinNum  = startNums[1]|0
      startNum = startHourNum * 60 + startMinNum

      endNums = (end).split ':'
      endHourNum = endNums[0]|0
      endMinNum  = endNums[1]|0
      endNum = endHourNum * 60 + endMinNum

      dateObj = new Date()
      nowHourNum = dateObj.getHours()
      nowMinNum  = dateObj.getMinutes()
      nowNum = nowHourNum * 60 + nowMinNum

      if startNum <= endNum and
         startNum <= nowNum and nowNum <= endNum
        return true
      else if startNum > endNum and
         (startNum <= nowNum or nowNum <= endNum)
        return true

      return false

    ###*
     * Calculate time to start time
    ###
    calcTime2start: (time) ->
      start = time.start

      startNums = (start).split ':'
      startHourNum = startNums[0]|0
      startMinNum  = startNums[1]|0
      startNum = startHourNum * 60 + startMinNum

      dateObj = new Date()
      nowHourNum = dateObj.getHours()
      nowMinNum  = dateObj.getMinutes()
      nowNum = nowHourNum * 60 + nowMinNum

      toStart = 0
      if nowNum <= startNum
        toStart = (startNum - nowNum)*60*1000
      else
        toStart = (24*60-nowNum+startNum)*60*1000

      return toStart

    ###*
     * Calculate time to end time
    ###
    calcTime2end: (time) ->
      end = time.end

      endNums = (end).split ':'
      endHourNum = endNums[0]|0
      endMinNum  = endNums[1]|0
      endNum = endHourNum * 60 + endMinNum

      dateObj = new Date()
      nowHourNum = dateObj.getHours()
      nowMinNum  = dateObj.getMinutes()
      nowNum = nowHourNum * 60 + nowMinNum

      toEnd = 0
      if nowNum <= endNum
        toEnd = (endNum - nowNum)*60*1000
      else
        toEnd = (24*60-nowNum+endNum)*60*1000

      return toEnd
  }