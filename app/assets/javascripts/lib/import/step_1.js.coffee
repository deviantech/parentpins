window.prevImportedPins = []

window.togglePrevImported = () ->
  window.prevImportedShown = !window.prevImportedShown
  afterVisiblePinsChanged()
  $('.js-togglePrevImported').text(if window.prevImportedShown then 'Hide Previously Imported' else 'Show Previously Imported')

$(document).ready () ->
  if $('.context.import.step_1').length
    
    prevImportedData = $('#import_form').data('previously-imported')
    if typeof(prevImportedData) == 'string' then prevImportedData = $.parseJSON(prevImportedData)
    
    for pin in $('.drag_section_wrapper li.pin')
      $pin = $(pin)
      if images = prevImportedData[ $pin.data('pin-url') ]
        if images.indexOf( $pin.data('pin-image') ) > -1
          $pin.addClass('prev-imported')
          window.prevImportedPins.push($pin)
        
    if window.prevImportedPins.length
      $('.js-togglePrevImported').css('display', 'inline-block')

      window.prevImportedShown = true
      togglePrevImported()
      $('.js-togglePrevImported').on 'click touchend', (e) ->
        e.preventDefault()
        togglePrevImported()
      
