//= require underscore.min
//= require jquery.ui.selectable
//= require jquery.ui.draggable
//= require jquery.ui.droppable
//= require app/importer/shared
//= require app/importer/step_1
//= require app/importer/step_2
//= require app/importer/step_2_new

$(document).ready () ->  
  if $('body').hasClass('step_2')
    window.initStep2()
  if $('body').hasClass('step_1')
    window.initStep1()    
  if $('body').hasClass('step_2_new')
    window.initStep2New()
