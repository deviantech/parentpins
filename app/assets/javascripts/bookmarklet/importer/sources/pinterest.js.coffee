window.ppImporterClasses ?= {}
window.ppImporterClasses.Sources ?= {}

class window.ppImporterClasses.Sources.Pinterest

  # Global class config
  outputDiv         = $('#ppBookmarkletContent')
  progressDiv       = outputDiv.find('#noPotentialImages')
  appendTarget      = outputDiv
  debug             = true
  
  # Data selectors
  boardSelector     = '.UserBoards .item.gridSortable a.boardLinkWrapper'
  pinSelector       = '.pinWrapper'
  pinsPending       = 'unknown'
  
  # TODO: shared with interactivity... also, why needed when updating div contents?
  toggleWindowRepaint = () ->
    body = $('body').first()
    curHeight = body.height()
    body.height(curHeight - 1).height(curHeight)
  
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
  hashFromString: (str) ->
    hash = 0
    return hash if str.length == 0
    i = 0
    while i < @length
      char = @charCodeAt(i)
      hash = ((hash << 5) - hash) + char
      hash = hash & hash # Convert to 32bit integer
      i++
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
      pin.url =       @parent.parent.getIframeWindow(e.currentTarget).jQuery('.detailed.Pin.Module .pinWrapper a').first().prop('href')
      pin.imageURL =  @parent.parent.getIframeWindow(e.currentTarget).jQuery('.detailed.Pin.Module .pinWrapper img.pinImage').first().prop('src')
      @finalizedAPin(pin)

  # =====================
  # = Processing Boards =
  # =====================
  processABoard: (board) ->
    processingThisBoard = new $.Deferred()
    board     = $(board)
    boardURL  = board.prop('href')
    boardName = $.trim( board.find('.boardName').text() )
    boardID   = @hashFromString(boardURL)
    @reportProgress "Starting to process board: #{boardName}"

    iframe = $('<iframe class="ppBoardDetailFrame">').hide().attr('src', boardURL).appendTo( appendTarget )
    iframe.show().css({position: 'absolute', left: '50px', top: '500px', height: '500px', width: '500px', border: '2px solid #333', 'z-index': 9999999999999}) if debug

    processingThisBoard.done () =>
      @boardsPending -= 1
      @boardsData.push({name: boardName, pinterestURL: boardURL, id: boardID})
      @reportProgress "Finished processing board: #{boardName}"
      @processingAllBoards.resolve() if @boardsPending == 0

    processBoardDetails = () =>
      @reportProgress "Loaded iframe for board: #{boardName}"
      frame$ = @parent.parent.getIframeWindow(iframe.get(0))
      
      # Scroll iframe down to try lazy loading later images
      frame$(iframe).contents().scrollTop( frame$(iframe).contents().height() )

      frame$(pinSelector, iframe.contents()).each (pidx, pin) =>
        pin = frame$(pin)
        pinData = {
          description:    pin.find('.pinDescription').text(),
          domain:         pin.find('.pinDomain').text(),
          price:          pin.find('.priceValue').text(),
          smallImageURL:  pin.find('.pinImg.loaded').prop('src'),
          pinterestURL:   pin.find('a.pinImageWrapper').prop('href')
        }
        pinData.id = @hashFromString "#{boardID}:#{pinData.pinterestURL}"
        pinsData.push pinData
      processingThisBoard.resolve()

  
    iframeAjaxSeen_Categories = false
    iframeAjaxSeen_Board      = false
    alreadyProcessingBoard    = false
    
    iframe.on 'load', (e) =>
      # Don't fully understand, but ajaxComplete seems to only work if use the jquery from the inner window 
      # (see untested answer on http://stackoverflow.com/questions/14563041/detect-content-of-iframe-change-the-content-is-dynamic-jquery-mobile) 
      @parent.parent.getIframeWindow(e.currentTarget).jQuery(@parent.parent.getIframeWindow(e.currentTarget).document).ajaxComplete (event, xhr, settings) ->
        console.log "ajaxComplete from frame (for board #{boardName}): just loaded #{settings.url}"
        return if alreadyProcessingBoard
        iframeAjaxSeen_Categories = true if /resource\/CategoriesResource\/get/.test(settings.url)
        iframeAjaxSeen_Board      = true if /resource\/BoardFeedResource\/get/.test(settings.url)

        # TODO: how handle if too many pins in board, pagination required?
        if (iframeAjaxSeen_Categories && iframeAjaxSeen_Board)
          alreadyProcessingBoard = true
          setTimeout(processBoardDetails, 100)
    

