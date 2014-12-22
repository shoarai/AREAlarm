'use strict'

do ->
  if navigator.userAgent.indexOf('Android') > 0
    script = document.createElement('script');
    script.type = 'text/javascript'
    script.src = 'http://192.168.0.3:8080/target/target-script-min.js#sho'
    target = document.getElementsByTagName('script')[0]
    target.parentNode.insertBefore script, target