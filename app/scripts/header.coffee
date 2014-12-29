'use strict'

angular.module('AREAlarm')

.directive 'license', ($ionicPopup, mapService) ->
  return {
    restrict: 'A'
    link: (scope, element) ->
      element.on('click', ->
        mapService.getLicenseInfo()
          .then(
            (text) ->
              console.log  '================'
              $ionicPopup.alert {
                title: 'Legal Notices'
                template: text
                okText: 'Close'
              }
              # navigator.notification.alert text, null, 'Legal Notices'
          )
        )
  }