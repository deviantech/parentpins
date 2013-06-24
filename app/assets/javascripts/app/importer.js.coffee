//= require underscore.min
//= require jquery.ui.selectable
//= require jquery.ui.draggable
//= require jquery.ui.droppable
//= require app/importer/shared
//= require app/importer/step_1
//= require app/importer/step_4
//= require app/importer/steps_drag_to_assign

$(document).ready () ->  
  if $('body').hasClass('step_1')
    window.initStep1()    
  if $('body').hasClass('step_drag_to_assign')
    window.initStepDragToAssign()
  if $('body').hasClass('step_4')
    window.initStep4()



