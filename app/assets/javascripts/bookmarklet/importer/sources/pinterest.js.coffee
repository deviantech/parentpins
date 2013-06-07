window.ppImporterClasses ?= {}
window.ppImporterClasses.Sources ?= {}

class window.ppImporterClasses.Sources.Pinterest

  # Global class config
  outputDiv         = $('#ppBookmarkletContent')
  progressDiv       = outputDiv.find('#noPotentialImages')
  appendTarget      = outputDiv
  debug             = true
  
  # Data selectors
  boardSelector     = '.UserBoards .item.gridSortable a.boardLinkWrapper, .secretBoardWrapper .item a.boardLinkWrapper'
  pinSelector       = '.pinWrapper'
  pinsPending       = 'unknown'
  
  # TODO: shared with interactivity... also, why needed when updating div contents?
  toggleWindowRepaint = () ->
    body = $('body').first()
    curHeight = body.height()
    body.height(curHeight - 1).height(curHeight)
  
  # Clean up after ourselves when bookmarklet closes
  bookmarkletClosing: () ->
    outputDiv.find('iframe.ppPinDetailFrame, iframe.ppBoardDetailFrame').remove()
  
  constructor: (@parent) ->
    @boardsData = []
    @pinsData = []

  getData: (callback) ->
    @boardsPending = $(boardSelector).length
    @processingAllBoards = new $.Deferred()
    @processingAllPins = new $.Deferred()

    # Once collected all data, pass it along to the callback function
    @processingAllPins.done () =>
      @reportProgress('Done processing all pins')
      progressDiv.hide()
      callback({boards: @boardsData, pins: @pinsData})

    @processingAllBoards.done () =>
      @reportProgress "Done processing all boards"
      @pinsPending = @pinsData.length
      @reportProgress "Beginning to process pins (#{@pinsPending})"
      @processAPin(pin) for pin in @pinsData

    # Now start actually getting data
    @reportProgress "Collecting boards"
    if $(boardSelector).length
      $(boardSelector).each (bidx, board) =>
        @processABoard(board)
    else
     @reportProgress "No boards found!", 'red'

    
  reportProgress: (message, color) ->
    console.log "ReportProgress: #{message}"
    # TODO: make report contents prettier for end user
    # msg = if @boardsPending == 0
    #   "Completed all boards! Collecting pin details... ("+@pinsPending+" remaining)"
    # else if @boardsPending == 1
    #   "Collecting account information: one board remaining..."
    # else
    #   "Collecting account information: " + @boardsPending + ' boards remaining...'
    progressDiv.html(message)    
    progressDiv.addClass('red') if color == 'red' # TODO: add ability to set color
    toggleWindowRepaint()

  # http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/ , converted to coffeescript, returning absolute value. Generating IDs for pinterest pins/boards, return as string.
  hashFromString: (string) ->
    hash = 0
    return hash if !string || string.length == 0
    for letter in string
      char = letter.charCodeAt(0)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash # Convert to 32bit integer      
    Math.abs(hash) + ''

  # ===================
  # = Processing Pins =
  # ===================
  finalizedAPin: (pin) ->
    @pinsPending -= 1
    @reportProgress "Processed a pin: #{pin.pinterestURL || '[invalid]'}"
    if @pinsPending == 0 then @processingAllPins.resolve()

  processAPin: (pin) ->
    unless pin.pinterestURL
      @finalizedAPin(pin)
      return

    pinFrame = $('<iframe class="ppPinDetailFrame">').hide().attr('src', pin.pinterestURL).appendTo( appendTarget )
    console.log('opening '+pin.pinterestURL)
    pinFrame.on 'load', (e) =>
      pin.url =       @parent.getIframeWindow(e.currentTarget).jQuery('.detailed.Pin.Module .pinWrapper a').first().prop('href')
      pin.imageURL =  @parent.getIframeWindow(e.currentTarget).jQuery('.detailed.Pin.Module .pinWrapper img.pinImage').first().prop('src')
      @finalizedAPin(pin)
      pinFrame.remove()

  # =====================
  # = Processing Boards =
  # =====================
  processABoard: (board) ->
    frameDoc = null
    processingThisBoard = new $.Deferred()
    
    board         = $(board)
    boardURL      = board.prop('href')
    boardName     = $.trim( board.find('.boardName').text().replace(/^\s*Secret Board\s*/i, '') )
    boardID       = @hashFromString(boardURL)
    expectedPins  = parseInt board.find('.boardPinCount').text().replace(/pins?/, ''), 10
    @reportProgress "Starting to process board: #{boardName}"

    iframe = $('<iframe class="ppBoardDetailFrame">').hide().attr('src', boardURL).appendTo( appendTarget )
      
    if debug
      frameIdx = $('iframe.ppBoardDetailFrame').length
      iframe.show().css({position: 'absolute', left: "#{50 * frameIdx}px", top: '100px', height: '100px', width: '100px', border: '2px solid #333', 'z-index': 9999999999999})
    
    processingThisBoard.done () =>
      iframe.remove()
      @boardsPending -= 1
      @boardsData.push({name: boardName, pinterestURL: boardURL, id: boardID, numPins: expectedPins})
      @reportProgress "Finished processing board: #{boardName}"
      @processingAllBoards.resolve() if @boardsPending == 0

    processBoardDetails = () =>
      @reportProgress "Collecting pins for board: #{boardName}"
      
      frame$ = @parent.getIframeWindow(iframe).jQuery
      frame$(pinSelector, frameDoc).each (pidx, pin) =>
        pin = frame$(pin)
        pinData = {
          board_id:       boardID,
          description:    pin.find('.pinDescription').text(),
          domain:         pin.find('.pinDomain').text(),
          price:          pin.find('.priceValue').text(),
          smallImageURL:  pin.find('.pinImg.loaded').prop('src'),
          pinterestURL:   pin.find('a.pinImageWrapper').prop('href')
        }
        pinData.id = @hashFromString "#{boardID}:#{pinData.pinterestURL}"
        @pinsData.push pinData
      processingThisBoard.resolve()

      
    # After load, wait for various ajax events to finish
    iframe.on 'load', () =>
      frameDoc = $(iframe).contents()
      
      if isNaN(expectedPins)
        console.log "Unable to parse number of expected pins for board (#{boardName}), so waiting two seconds and hoping for the best"
        setTimeout processBoardDetails, 3000
      else
        timeout = 15 * 1000
        foundAllPins = null
      
        periodicCheck = () ->
          seen = frameDoc.find('.Pin.Module').length
          if expectedPins == seen
            foundAllPins = true
            clearInterval(pinCountChecker)
            processBoardDetails()
          else if debug && seen > 0 # Page requires scrolling to spur loading additional pins
            frameDoc.scrollTop( frameDoc.height() )
            console.log "Wanted #{expectedPins}, so far only seen #{seen}. Scrolling down..."
          else if debug
            console.log "Wanted #{expectedPins}, so far only seen #{seen}"
        
        pinCountChecker = setInterval periodicCheck, 500
        
        timeOutIfRequired = () ->
          unless foundAllPins
            clearInterval(pinCountChecker)
            console.log "Board (#{boardName}) timed out trying to load all pins"
            processBoardDetails() # Will fail to find all pins, but can at least work with what we have
            # TODO: somehow indicate to user that some pins weren't collected
        
        setTimeout timeOutIfRequired, timeout

