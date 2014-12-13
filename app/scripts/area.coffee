'use strict'

angular.module('AREAlarm')

.directive('areaselect', ($ionicPlatform) ->

	map = {}


	onSuccess = (location) ->
	  msg = ["Current your location:\n",
	    "latitude:" + location.latLng.lat,
	    "longitude:" + location.latLng.lng,
	    "speed:" + location.speed,
	    "time:" + location.time,
	    "bearing:" + location.bearing].join '\n'

	  map.addMarker {
		    'position': location.latLng,
		    'title': msg
	  	},
	  	(marker) ->
	    	marker.showInfoWindow()
	  
	  console.log msg

	  map.animateCamera {
		  'target': new plugin.google.maps.LatLng location.latLng.lat, location.latLng.lng
		  # 'tilt': 60
		  'zoom': 15
		  'duration': 1000
		  # 'bearing': 140
		}

	  


		onError = ->
			console.log 'error'

		controller = ($scope) ->
			$scope.onClickLocate = ->
				console.log 'here'
				map.getMyLocation onSuccess, onError

  $ionicPlatform.ready ->
    if plugin?
      div = document.getElementById 'map_canvas'
      map = plugin.google.maps.Map.getMap div

  return {
    restrict: 'E',
    replace: true,
    templateUrl: 'templates/area.html',
    controller: controller
    # link: (scope, element, attrs) ->
      # return
  }
)