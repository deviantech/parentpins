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
    if $('#pp_pinterest_import_wrapper').length
      height = $('#pp_pinterest_import_wrapper').height() + $('#pp_pinterest_import_wrapper').offset().top + 15
      sendMessage("step1:setHeight:#{height}")    

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

  # Starts with all pins in the not_yet_imported, then this moves the imported ones elsewhere
  moveToSectionIfPreviouslyImported = (li) ->
    li = $(li)
    
    prev_imported = false
    for knownImageURL in (prevImported[li.data('pin-url')] || [])
        if knownImageURL == li.data('pin-image') then prev_imported = true

    if prev_imported
        li.addClass('already-imported').appendTo(imported)

  not_yet_imported.find('li.pin').each () ->
    moveToSectionIfPreviouslyImported(this)

  $('#our_section ul.ourBoardPins li').each () ->
    moveToSectionIfPreviouslyImported(this)

  checkIfAnyDraggableLeft()


hideShowPinsForSelectedBoard = () ->
  class_to_show = if $('.importing_boards li.selected').length then $('.importing_boards li.selected').data('class') else 'board-all'
  soon = () =>
    $('.importing_pins li.pin').hide().removeClass('ui-selected').addClass('hidden')
    $('.importing_pins li.pin.' + class_to_show).show().removeClass('hidden')
    checkIfAnyDraggableLeft()

  # Give JS time to reset to having dropped pin (not sure why, but required)
  setTimeout soon, 1

checkIfAnyDraggableLeft = () ->
  updateBoardPendingPinsCounters()
  $('.importing_pins').each (i, section) =>
    section = $(section)
    # Using .hidden, not :visible, to count current board's pins because when initializing when loading in iframe :visible returns false (because iframe itself isn't completely visible yet?)
    if section.find('li.pin:not(.hidden)').length == 0
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

updateDroppedPinCounts = () ->
  wrappedUpdateFn = () ->
    for board in $('#our_section li.board')
      $board = $(board)
      count = $board.find('li.pin').length
      msg = if count == 1 then "1 pin added" else "#{count} pins added"
      $board.find('.ourBoardInfo').text(msg)
  setTimeout wrappedUpdateFn, 5


# Add draggable/droppable effects
initDragDrop = () ->
  section = $('#our_section')
  
  # TODO - consider replacing with smooth scrolling. Unfortunately need calculations on the fly because offsets change as boards shown/hidden and pins assigned
  considerScrollingDroppableContainer = (y) ->
    dropTop = section.offset().top
    dropBottom = dropTop + section.height()
    scrollHeight = section[0].scrollHeight
    sensitivityRange = scrollHeight * 0.15
    jump = 10
  
    scrollUp    = {min: dropTop - 25, max: dropTop + sensitivityRange}
    scrollDown  = {min: dropBottom - sensitivityRange, max: dropBottom}    
    if y > scrollUp.min && y < scrollUp.max
      section.scrollTop( section.scrollTop() - jump )
    
    if y > scrollDown.min
      section.scrollTop( section.scrollTop() + jump )
  
  
  drop = {
    overOurBoards: {
      hoverClass: "ui-droppable-hovering",
      tolerance: 'pointer',
      accept: (draggable) ->
        return !draggable.parents().is(this)
      drop: (event, ui) ->
        li = $(ui.draggable).addClass('assigned')
        helper = $(ui.helper)
        target = $(this).find('.ourBoardPins')

        toAdd = if helper.hasClass('multi-drag-helper')
          helper.data('origElements')
        else if li.hasClass('pin')      
          li
        else # Dropped a pinterest board. If currently showing previously imported, move ALL in board. Otherwise, only move not-yet-imported over.
          $('.importing_pins li.pin.' + li.data('class'))

        toAdd.css('opacity', 1.0).addClass('assigned').draggable('destroy').draggable(drag.pinsFromOurBoards).appendTo(target)
        hideShowPinsForSelectedBoard()
        updateDroppedPinCounts()
      deactivate: (event, ui) ->
        $('li.pin').css({opacity: 1.0})
    },
    overPinterestBoards: {
      hoverClass: "ui-droppable-hovering",
      accept: 'li.pin.assigned',
      tolerance: 'pointer',
      drop: (event, ui) ->
        li = $(ui.draggable).removeClass('assigned')
        target = if li.hasClass('already-imported')
          $(this).find('.importing_pins.previously_imported ul')
        else
          $(this).find('.importing_pins.not_yet_imported ul')

        li.draggable('destroy').draggable(drag.pinsFromPinterest).appendTo(target)
        hideShowPinsForSelectedBoard()
        updateDroppedPinCounts()
    }
  }
  
  drag = {
    general: {
      revert: 'invalid',
      helper: 'clone',
      cursor: "move",
      containment: '#pp_pinterest_import_wrapper',
      delay: 0,
      distance: 0,
      start: (event, ui) ->
        $(event.target).css({opacity: 0.5})
      stop: (event, ui) ->
        $(event.target).css({opacity: 1.0})
        updateDroppedPinCounts() # Can't rely on this, because overridden by multiDragOpts
      drag: (event, ui) -> 
        considerScrollingDroppableContainer(event.pageY)
    }
  }
  drag.externalBoards = $.extend({}, drag.general, {stack: '.importing_boards li'})
  drag.pinsFromOurBoards =           $.extend({}, drag.general, {stack: '#our_section li.board'})
  drag.pinsFromPinterest =           $.extend({}, drag.general, {stack: '#our_section li.board'}, window.multiDragOpts)
  
  
  if $('.importing_boards li').length   then $('.importing_boards li').draggable    drag.externalBoards
  if $('.importing_pins li.pin').length then $('.importing_pins li.pin').draggable  drag.pinsFromPinterest
  if $('#our_section li.board').length  then $('#our_section li.board').droppable   drop.overOurBoards
  $('#pinterest_section').droppable drop.overPinterestBoards

  $('#pinterest_section').disableSelection().find('ul.collection').selectable({})  
  updateDroppedPinCounts()

  # Used when boards added via ajax
  window.stepOneAddDroppableBoard = (board) ->
    target = $('#our_section ul.boards')
    $(board).droppable(drop.overOurBoards).hide().appendTo( target ).fadeIn () ->
      tellParentOurHeight()
    target.find('.no-pp-boards').hide()



updateBoardPendingPinsCounters = () ->
  boards = $('#pinterest_section .importing_boards li.board')
  if boards.length
    allEmpty = true
    boards.each () ->
      board = $(this)
      counter = board.find('.counter')
      if counter.length
        count = $("#pinterest_section .pin_lists li.pin.#{board.data('class')}").length
        counter.html("(#{count})")
        allEmpty = false unless count == 0
        if count == 0 then board.addClass('empty') else board.removeClass('empty')

    firstBoard = boards.first()
    if allEmpty then firstBoard.addClass('empty') else firstBoard.removeClass('empty')


$(document).ready () ->
  wrapper = $('body.importing.step_1')
  if wrapper.length
    sendMessage("step1:loaded")
    updateBoardPendingPinsCounters()

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


    # Only show pins from selected board
    $('body').on 'mousedown', '.importing_boards li', (e) =>
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