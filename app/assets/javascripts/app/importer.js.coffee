//= require underscore.min
//= require app/importer/shared
//= require app/importer/step_1
//= require app/importer/step_2

$(document).ready () ->
  if $('body').hasClass('step_2')
    window.initStep2()
  if $('body').hasClass('step_1')
    window.initStep1()