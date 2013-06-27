//= require underscore.min
//= require jquery.ui.draggable
//= require jquery.ui.droppable

sendMessage = (msg, explanation) ->
  if (!window.parent)
    if explanation then alert("Sorry, can't " + explanation + " because page doesn't appear to have been loaded in a bookmarklet context.")
  else if (!window.parent.postMessage)
    if explanation then alert("Sorry, can't " + explanation + " because your browser appears too old to support modern web standards.")
  else
    window.parent.postMessage(msg, '*')

prevImported = null

dataToSubmit = () ->
  allPinData = $('#pp_pinterest_import_wrapper').data('all-pins')
  pinsToSubmit = []

  dataForPinID = (pid) =>
    for pin in allPinData
      return pin if (pin.external_id + '') == (pid + '')
    null

  # Get full data for all pins to import  
  for board in $('#our_section li.board')
    theBoardID = $(board).data('boardId')
    for pin in $(board).find('.ourBoardPins li')
      thePinID = $(pin).data('pinExternalId')
      if pinData = dataForPinID(thePinID)
        pinData.board_id = theBoardID
        pinsToSubmit.push(pinData)

  if pinsToSubmit.length > 0
    $.param({pins: pinsToSubmit})
  else
    null



tellParentOurHeight = () ->
  if $('body').is(':visible')
    updateBoardHeight()
    height = $('#pp_pinterest_import_wrapper').height() + $('#pp_pinterest_import_wrapper').offset().top + 15
    sendMessage("step1:setHeight:#{height}")    

# TODO: Remove this once CSS fixed for modifying board height
updateBoardHeight = () ->
  if $('.importing_boards ul').length
    max = $('#pinterest_section').height() - $('.importing_boards ul').offset().top - 20
    $('.importing_boards ul').css({'max-height': max})


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
  class_to_show = if $('.importing_boards li.selected').length then $('.importing_boards li.selected').attr('class').replace(/\s*selected\s*/, '').replace(/\s*ui-\w+\s*/g, '') else 'board-all'
  soon = () =>
    $('.importing_pins li.pin').hide()
    $('.importing_pins li.pin.' + class_to_show).show()
    checkIfAnyDraggableLeft()

  # Give JS time to reset to having dropped pin (not sure why, but required)
  setTimeout soon, 1

checkIfAnyDraggableLeft = () ->
  $('.importing_pins').each (i, section) =>
    section = $(section)
    if section.find('li.pin').length == 0
      kind = if section.hasClass('not_yet_imported') 
       'not-yet-imported'
      else
       'previously imported'
      board_label = if $('.importing_boards').length == 0 || $('.importing_boards li.selected').first().hasClass('board-all')
        ''
      else
        'on this board'

      section.find('.no-more').remove()
      section.find('ul').append("<div class='no-more'>List of "+kind+" pins "+board_label+" is empty.</div>")
    else
      section.find('.no-more').remove()
  tellParentOurHeight()


# Add draggable/droppable effects
initDragDrop = () ->
  dropOpts = {
    hoverClass: "ui-droppable-hovering",
    tolerance: 'pointer',
    drop: (event, ui) ->
      li = $(ui.draggable).addClass('assigned')
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
    hoverClass: "ui-droppable-hovering",
    accept: 'li.pin.assigned',
    tolerance: 'pointer',
    drop: (event, ui) ->
      li = $(ui.draggable).removeClass('assigned')
      base = if li.hasClass('already-imported')
        $(this).find('.importing_pins.previously_imported ul')
      else
        $(this).find('.importing_pins.not_yet_imported ul')

      base.append( li.css({left: 0, top: 0}) )
      hideShowPinsForSelectedBoard()
  }
  generalDragOpts = {
    revert: 'invalid',
    helper: 'clone',
    cursor: "move", 
    cursorAt: { top: -5, left: -5 },
    containment: '#pp_pinterest_import_wrapper',
    start: (event, ui) ->
      $(event.target).css({opacity: 0.5})
    stop: (event, ui) ->
      $(event.target).css({opacity: 1.0})
  }

  # Used when boards added via ajax
  window.stepOneAddDroppableBoard = (board) ->
    $(board).droppable(dropOpts).hide().appendTo( $('#our_section ul.boards') ).fadeIn () ->
      tellParentOurHeight()

  if $('.importing_pins li.pin').length
    $('.importing_pins li.pin').draggable $.extend({}, generalDragOpts, {stack: $('#our_section li.board')})
  if $('.importing_boards li').length
    $('.importing_boards li').draggable   $.extend({}, generalDragOpts, {stack: $('.importing_boards li')})
  if $('#our_section li.board').length
    $('#our_section li.board').droppable(dropOpts)
  $('#pinterest_section').droppable(dropToPinterestOpts)


$(document).ready () ->
  sendMessage("step1:loaded")

  initial = $('.importing_pins.previously_imported').data('initial')
  if typeof(initial) == 'string' then initial = $.parseJSON(raw)
  handlePreviouslyImportedData(initial)
  initDragDrop()

  # Tell parent how tall we are
  tellParentOurHeight()

  # Handle Submit Button
  $('#ppSubmitBoardsSortedForm').on 'submit', (e) =>
    data = dataToSubmit()
    if data
      $('#ppSubmitBoardsSortedForm').find('#data_string').val( data )
    else
      alert("You haven't yet selected any pins to import. Please drag at least one Pinterest pin down onto the ParentPins board you want to save it to.")
      e.preventDefault()    

  # Handle Reset Button
  $('#ppResetDragDropLink').on 'click', () =>
    handlePreviouslyImportedData(null, true)

  # Handle show/hide previous
  $('#ppTogglePreviouslyImportedPins').on 'click', (e) =>
    imported = $('.importing_pins.previously_imported')
    link = $(e.currentTarget)
    if imported.is(':visible')
      link.text('Show Previously Imported')
      imported.slideUp () ->
        checkIfAnyDraggableLeft()
    else
      link.text('Hide Previously Imported')
      imported.slideDown () ->
        checkIfAnyDraggableLeft()



  # Only show pins from selected board
  $('body').on 'click', '.importing_boards li', (e) =>
    $(e.currentTarget).addClass('selected').siblings().removeClass('selected')
    hideShowPinsForSelectedBoard()

 # Allow step 2 to tell parent to tell step 1 when new pins have been imported
 $(window).on 'message', (evt) =>
   [command, extra...] = evt.originalEvent.data.split(':')
   if command == 'step4' # Pass events from opened window on to parent
     sendMessage(evt.originalEvent.data)
   else
     extra = extra.join(':')
     if command == 'imported'
        pins = $.parseJSON(extra)
        handlePreviouslyImportedData(pins)
        setTimeout(checkIfAnyDraggableLeft, 1) # Doesn't seem like it should be necessary... but is, or else sections leave the 'empty' div in place while showing pins

  $(window).on 'resize', tellParentOurHeight