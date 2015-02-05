'use strict'

angular.module('AREAlarm')


.directive 'admob', ($ionicPlatform) ->
  return {
    restrict: 'A'
    controller: ['$scope', ($scope) ->
      $ionicPlatform.ready ->
        admob.initAdmob(
          '', # bannar ID
          '') # interstitial ID
        admob.showBanner admob.BannerSize.BANNER, admob.Position.BOTTOM_CENTER
        return
    ]
  }
