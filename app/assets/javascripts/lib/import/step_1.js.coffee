handlePreviouslyImportedData = (data, resetAllAlreadyMovedPins) ->
  if prevImported # If already have some, append to the imported list
    if data
      # Just add the URLs given to the ones we already know
      for url of data
        if prevImported[url]
          for imgURL in (data[url] || [])
            prevImported[url].push(imgURL)
        else
          prevImported[url] = data[url]
  else
    prevImported = data
  
  not_yet_imported = $('.importing_pins.not_yet_imported ul')
  imported = $('.importing_pins.previously_imported ul')

  # In case any already assigned a board, move back to main section
  if resetAllAlreadyMovedPins
    $('#our_section ul.ourBoardPins li').each () ->
      $(this).appendTo(not_yet_imported)


prevImportedShown = true

togglePrevImported = () ->

  for pin in $('.drag_section_wrapper li.pin')
    data = $(pin).data()
    images = prevImported[ data['pin-url'] ]
    if images
      console.log(images)

  prevImportedShown = !prevImportedShown    

$(document).ready () ->
  if $('.context.import.step_1').length
    
    window.prevImported = $('#import_form').data('previously-imported')
    if typeof(prevImported) == 'string' then window.prevImported = $.parseJSON(prevImported)
    
    togglePrevImported()
        
    if Object.keys(prevImported).length == 0
      $('.js-togglePrevImported').hide()
    else
      $('.js-togglePrevImported').on 'click touchend', (e) ->
        e.preventDefault()
        togglePrevImported()
      
