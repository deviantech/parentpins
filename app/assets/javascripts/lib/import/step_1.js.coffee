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


togglePrevImported = () ->
  console.log('clicked')

$(document).ready () ->
  if $('.context.import.step_1').length
    $('.js-togglePrevImported').on 'click touchend', (e) ->
      e.preventDefault()
      togglePrevImported()
    
    initial = $('.importing_pins.previously_imported').data('initial')
    if typeof(initial) == 'string' then initial = $.parseJSON(raw)
    handlePreviouslyImportedData(initial)

    # Handle Reset Button
    $('#ppResetDragDropLink').on 'click', (e) =>
      e.preventDefault();
      handlePreviouslyImportedData(null, true)
    
    # Handle show/hide previous
    $('#ppTogglePreviouslyImportedPins').on 'click', (e) =>
      e.preventDefault();
      imported = $('.importing_pins.previously_imported')
      ul = imported.find('ul.collection')
      link = $(e.currentTarget)
      if ul.is(':visible')
        link.text('(show)')
        ul.slideUp () ->
          checkIfAnyDraggableLeft()
      else
        imported.find('.no-more').remove()
        link.text('(hide)')
        ul.slideDown () ->
          checkIfAnyDraggableLeft()