'use strict'

angular.module('AREAlarm')


.directive 'admob', ($ionicPlatform) ->

  return {
    restrict: 'A'
    controller: ['$scope', ($scope) ->
      $ionicPlatform.ready ->
        id = 'ca-app-pub-6869992474017983/9375997553'
        admobAd.initBanner id, admobAd.AD_SIZE.BANNER.width, admobAd.AD_SIZE.BANNER.height
        admobAd.showBanner admobAd.AD_POSITION.BOTTOM_CENTER
        return
    ]
  }


.directive 'admob2', ($ionicPlatform) ->
  initAd = ->
    if window.plugins && window.plugins.AdMob
      ad_units =
        # ios:
        #   banner: 'ca-app-pub-6869992474017983/4806197152',
        #   interstitial: 'ca-app-pub-6869992474017983/7563979554'
        android:
          banner: 'ca-app-pub-6869992474017983/9375997553',
          interstitial: 'ca-app-pub-6869992474017983/1657046752'
        # wp8:
        #   banner: 'ca-app-pub-6869992474017983/8878394753',
        #   interstitial: 'ca-app-pub-6869992474017983/1355127956'

      admobid = ''
      if /(android)/i.test(navigator.userAgent)
        admobid = ad_units.android
      else if /(iphone|ipad)/i.test(navigator.userAgent)
        admobid = ad_units.ios
      else
        admobid = ad_units.wp8

      window.plugins.AdMob.setOptions {
          publisherId: admobid.banner
          interstitialAdId: admobid.interstitial
          bannerAtTop: false    # set to true, to put banner at top
          overlap: false        # set to true, to allow banner overlap webview
          offsetTopBar: false   # set to true to avoid ios7 status bar overlap
          isTesting: false      # receiving test ad
          autoShow: true        # auto show interstitial ad when loaded
      }
      # registerAdEvents()
      
    else
      alert 'admob plugin not ready'

  # optional, in case respond to events
  registerAdEvents = ->
    document.addEventListener('onReceiveAd', ->)
    document.addEventListener('onFailedToReceiveAd', (data)->)
    document.addEventListener('onPresentAd', ->)
    document.addEventListener('onDismissAd', ->)
    document.addEventListener('onLeaveToAd', ->)
    document.addEventListener('onReceiveInterstitialAd', ->)
    document.addEventListener('onPresentInterstitialAd', ->)
    document.addEventListener('onDismissInterstitialAd', ->)

  return {
    restrict: 'A'
    controller: ['$scope', ($scope) ->
      $ionicPlatform.ready ->
        # initAd()
        # display the banner at startup
        # window.plugins.AdMob.createBannerView()
        return

    ]
  }