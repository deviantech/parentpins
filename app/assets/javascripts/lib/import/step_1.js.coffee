prevImportedPins = []

togglePrevImported = () ->
  if window.prevImportedShown 
    for pin in prevImportedPins
      $(pin).hide()
  else
    $('.drag_section_wrapper li.pin').show()

  window.prevImportedShown = !window.prevImportedShown
  $('.js-togglePrevImported').text(if window.prevImportedShown then 'Hide Previously Imported' else 'Show Previously Imported')
  checkIfAnyDraggableLeft()
  updateBoardPendingPinsCounters()

$(document).ready () ->
  if $('.context.import.step_1').length
    
    prevImportedData = $('#import_form').data('previously-imported')
    if typeof(prevImportedData) == 'string' then prevImportedData = $.parseJSON(prevImportedData)
    
    for pin in $('.drag_section_wrapper li.pin')
      $pin = $(pin)
      if images = prevImportedData[ $pin.data('pin-url') ]
        if images.indexOf( $pin.data('pin-image') ) > -1
          prevImportedPins.push($pin)
    
    
    if prevImportedPins.length
      $('.js-togglePrevImported').css('display', 'inline-block')
      togglePrevImported()
      $('.js-togglePrevImported').on 'click touchend', (e) ->
        e.preventDefault()
        togglePrevImported()
      
