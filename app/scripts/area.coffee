'use strict'

angular.module('AREAlarm')

.directive('areaselect', ($ionicPlatform) ->



  $ionicPlatform.ready ->
    if plugin?
      div = document.getElementById 'map_canvas'
      map = plugin.google.maps.Map.getMap div

  return {
    restrict: 'E'
    replace: true
    templateUrl: 'templates/area.html'
    controller: ['$scope', ($scope) ->



   #  	$scope.onClickLocate = ->
   #  		console.log 'here'
   #  		onSuccess = function(location) {
			#   msg = ["Current your location:\n",
			#     "latitude:" + location.latLng.lat,
			#     "longitude:" + location.latLng.lng,
			#     "speed:" + location.speed,
			#     "time:" + location.time,
			#     "bearing:" + location.bearing].join("\n");

			#   map.addMarker({
			#     'position': location.latLng,
			#     'title': msg
			#   }, function(marker) {
			#     marker.showInfoWindow();
			#   });
			# };

			# onError = function(msg) {
			#   alert("error: " + msg);
			# };
			# map.getMyLocation onSuccess, onError


   	]
    # link: (scope, element, attrs) ->
      # return
  }
)