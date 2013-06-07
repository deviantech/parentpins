prevImported = null

handleSubmission = () ->
  data = dataToSubmit()
  if data.length == 0
    alert("You haven't yet selected any pins to import. Please drag at least one Pinterest pin down onto the ParentPins board you want to save it to.")
  else
    sendMessage('step1:next:' + data.join(':'), 'continue to step 2')


dataToSubmit = () ->
  toImport = []
  
  for board in $('#our_section li.board')
    theBoardID = $(board).data('boardId')
    for pin in $(board).find('.ourBoardPins li')
      thePinID = $(pin).data('pinExternalId')
      toImport.push("#{theBoardID}.#{thePinID}")

  return toImport


handlePreviouslyImportedData = (data, resetAllAlreadyMovedPins) ->
  if prevImported # If already have some, append to the imported list
    if data
      _.each _.keys(data), (url) ->
        prevImported[url] ?= []
        prevImported[url] = _.union(prevImported[url], data[url])
  else
    prevImported = data

  not_yet_imported = $('.importing_pins.not_yet_imported ul')
  imported = $('.importing_pins.previously_imported ul')
 
  # In case any already assigned a board, move back to main section
  if resetAllAlreadyMovedPins
    $('#our_section ul.ourBoardPins li').each () ->
      $(this).appendTo(not_yet_imported)
 
  # Starts with all pins in the not_yet_imported, then this moves the imported ones elsewhere
  moveToSectionIfPreviouslyImported = (li) ->
    li = $(li)
    
    prev_imported = _.any prevImported[li.data('pin-url')], (importedImageURL) ->
      importedImageURL == li.data('pin-image')
 
    if prev_imported
        li.addClass('already-imported').appendTo(imported)
 
  not_yet_imported.find('li.pin').each () ->
    moveToSectionIfPreviouslyImported(this)
 
  $('#our_section ul.ourBoardPins li').each () ->
    moveToSectionIfPreviouslyImported(this)
 
  checkIfAnyDraggableLeft()


hideShowPinsForSelectedBoard = () ->
  class_to_show = $('.importing_boards li.selected').attr('class').replace(/\s*selected\s*/, '').replace(/\s*ui-\w+\s*/g, '')
  soon = () =>
    $('.importing_pins li.pin').hide()
    $('.importing_pins li.pin.' + class_to_show).show()
    checkIfAnyDraggableLeft()

  # Give JS time to reset to having dropped pin (not sure why, but required)
  setTimeout soon, 1

checkIfAnyDraggableLeft = () ->
  $('.importing_pins').each (i, section) =>
    section = $(section)
    if section.find('li.pin:visible').length == 0
      kind = if section.hasClass('not_yet_imported') 
       'not-yet-imported'
      else
       'previously imported'
      board_label = if $('.importing_boards li.selected').first().hasClass('board-all')
        ''
      else
        'on this board'
  
      section.find('.no-more').remove()
      section.find('ul').append("<div class='no-more'>List of "+kind+" pins "+board_label+" is empty.</div>")
    else
      section.find('.no-more').remove()


# Add draggable/droppable effects
initDragDrop = () ->
  dropOpts = {
    hoverClass: "ui-state-active",
    drop: (event, ui) ->
      li = $(ui.draggable)
      target = $(this).find('.ourBoardPins')
 
      if li.hasClass('pin')      
        target.append( li.css({left: 0, top: 0}) )
        hideShowPinsForSelectedBoard()
      else # Dropped a pinterest board. If currently showing previously imported, move ALL in board. Otherwise, only move not-yet-imported over.
        $('.importing_pins li.pin.' + li.attr('class').replace(/\s*selected\s*/, '').replace(/\s*ui-\w+\s*/g, '')+':visible').each () ->
          $(this).appendTo(target)
        hideShowPinsForSelectedBoard()
  }
  dropToPinterestOpts = {
    hoverClass: "ui-state-active",
    accept: 'li.pin',
    drop: (event, ui) ->
      li = $(ui.draggable)
      base = if li.hasClass('already-imported')
        $(this).find('.importing_pins.previously_imported ul')
      else
        $(this).find('.importing_pins.not_yet_imported ul')
 
      base.append( li.css({left: 0, top: 0}) )
      hideShowPinsForSelectedBoard()
  }
  dragOpts = {
    revert: 'invalid',
    stack: $('#our_section li.board'),
    helper: 'clone',
    start: (event, ui) ->
      $(event.target).css({opacity: 0.5})
    stop: (event, ui) ->
      $(event.target).css({opacity: 1.0})
  }
  pinterestBoardDragOpts = {
    revert: 'invalid',
    stack: $('.importing_boards li'),
    helper: 'clone',
    start: (event, ui) ->
      $(event.target).css({opacity: 0.5})
    stop: (event, ui) ->
      $(event.target).css({opacity: 1.0})
  }
 
  $('.importing_pins li.pin').draggable(dragOpts)
  $('.importing_boards li').draggable(pinterestBoardDragOpts)
  $('#our_section li.board').droppable(dropOpts)
  $('#pinterest_section').droppable(dropToPinterestOpts)
  
initBoardBackgroundOnHover = () ->
  showImageBG = (e) ->
    img = $(e.currentTarget).data('cover-image')
    if img? then $(e.currentTarget).css({'background-image': "url(#{img})"})
  
  hideImageBG = (e) ->
    $(e.currentTarget).css({'background-image': ""})
    
  $('#our_section li.board').hover(showImageBG, hideImageBG)

   
window.initStep1 = () ->
  initial = $('.importing_pins.previously_imported').data('initial')
  if typeof(initial) == 'string' then initial = $.parseJSON(raw)
  handlePreviouslyImportedData(initial)
  initDragDrop()
  initBoardBackgroundOnHover()

  # Handle Submit Button
  $('#ppSubmitBoardsSortedLink').on 'click', () =>
    handleSubmission()
  
  # Handle Reset Button
  $('#ppResetDragDropLink').on 'click', () =>
    handlePreviouslyImportedData(null, true)

  # Handle show/hide previous
  $('#ppTogglePreviouslyImportedPins').on 'click', (e) =>
    imported = $('.importing_pins.previously_imported')
    link = $(e.currentTarget)
    if imported.is(':visible')
      imported.slideUp()
      link.text('Show Previously Imported')
    else
      imported.slideDown()
      link.text('Hide Previously Imported')
    checkIfAnyDraggableLeft()

  # Only show pins from selected board
  $('body').on 'click', '.importing_boards li', (e) =>
    $(e.currentTarget).addClass('selected').siblings().removeClass('selected')
    hideShowPinsForSelectedBoard()
   
   # Allow step 2 to tell parent to tell step 1 when new pins have been imported
   $(window).on 'message', (evt) =>
     [command, extra...] = evt.originalEvent.data.split(':')
     extra = extra.join(':')
     if command == 'imported'
        pins = $.parseJSON(extra)
        handlePreviouslyImportedData(pins)
        setTimeout(checkIfAnyDraggableLeft, 1) # Doesn't seem like it should be necessary... but is, or else sections leave the 'empty' div in place while showing pins
        
  