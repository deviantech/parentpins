window.ppImporterClasses ?= {}
window.ppImporterClasses.Sources ?= {}

class window.ppImporterClasses.Sources.Pinterest

  # Config
  boardSelector     = '.UserBoards .item.gridSortable a.boardLinkWrapper'
  pinSelector       = '.pinWrapper'
  pinsPending = 'unknown'
  
  constructor: () ->
    boardsPending = $(boardSelector).length  
    processingAllBoards = new $.Deferred()
    processingAllPins = new $.Deferred()

  # TODO: finish converting this to module, return the data
  # TODO: now return object with boards and pins arrays, with IDs for each (see test data for format)
  # TODO: pin id calculation should include board id (so same pin in two boards gets unique ID). update the test data when completed.
  getData: () ->
  
    # Render template with the pinterest data
    processingAllPins.done () ->
      progressDiv.remove()
      transitionToStepOne()
  
    reportProgress = (custom) ->
      msg = if boardsPending == 0
        "Completed all boards! Collecting pin details... ("+pinsPending+" remaining)"
      else if boardsPending == 1
        "Collecting account information: one board remaining..."
      else
        "Collecting account information: " + boardsPending + ' boards remaining...'
      msg += " (tag: "+custom+")" if custom && debug
      progressDiv.text(msg)

    reportProgress('initial load')

    processingAllBoards.done () ->
      reportProgress('Done processing all boards')

      # Calculate how many to do
      pinsPending = 0
      for board in boardsData
        pinsPending += board.pins.length
      reportProgress('beginning to process pins')

      # Now start doing them
      for board in boardsData
        processThisPin(pin) for pin in board.pins

    finalizedAPin = (pin) ->
      pinsPending -= 1
      reportProgress('processed a pin: '+pin.pinterestURL)
      console.log(pin)
      if pinsPending == 0
        processingAllPins.resolve()

    processThisPin = (pin) ->
      unless pin.pinterestURL
        finalizedAPin(pin)
        return

      pinFrame = $('<iframe>').hide().attr('src', pin.pinterestURL).appendTo( $('body') )
      console.log('opening '+pin.pinterestURL)
      pinFrame.on 'load', () ->
        pin.link = this.parent.getIframeWindow(this).jQuery('.detailed.Pin.Module .pinWrapper a').first().prop('href')
        pin.imageURL = this.parent.getIframeWindow(this).jQuery('.detailed.Pin.Module .pinWrapper img.pinImage').first().prop('src')
        finalizedAPin(pin)

    # http://werxltd.com/wp/2010/05/13/javascript-implementation-of-javas-string-hashcode-method/ , converted to coffeescript, returning absolute value. Generating IDs for pinterest pins/boards, return as string.
    hashFromString = (str) ->
      hash = 0
      return hash  if @length is 0
      i = 0
      while i < @length
        char = @charCodeAt(i)
        hash = ((hash << 5) - hash) + char
        hash = hash & hash # Convert to 32bit integer
        i++
      Math.abs(hash) + ''
  
  
    getPinterestData = () ->
      $(boardSelector).each (bidx, board) ->
        processingThisBoard = new $.Deferred()
        $board = $(board)
        boardURL = $board.prop('href')
        boardName = $.trim( $board.find('.boardName').text() )
        boardPinData = []

        iframeAjaxSeen_Categories = false
        iframeAjaxSeen_Board = false
        alreadyProcessingBoard = false

        iframe = $('<iframe>').hide().attr('src', boardURL).appendTo( $('body') )
        iframe.show().css({position: 'absolute', left: '50px', top: (bidx*500)+'px', height: '500px', width: '500px', border: '2px solid #333', 'z-index': 9999999999999}) if debug

        processingThisBoard.done () ->
          boardsPending -= 1
          boardsData.push({
            name: boardName,
            pinterestURL: boardURL,
            pins: boardPinData,
            id: hashFromString(boardURL)
          })
          reportProgress('finished processing board: '+boardName)
          processingAllBoards.resolve() if boardsPending == 0

        processSingleBoard = () ->
          $ = this.parent.getIframeWindow(iframe.get(0))
          # Scroll iframe down to try lazy loading later images
          $(iframe).contents().scrollTop( $(iframe).contents().height() )

          iframe.contents().find(pinSelector).each (pidx, pin) ->
            $pin = $(pin)
            boardPinData.push({
              description: $pin.find('.pinDescription').text(),
              domain: $pin.find('.pinDomain').text(),
              price: $pin.find('.priceValue').text(),
              smallImageURL: $pin.find('.pinImg.loaded').prop('src'),
              pinterestURL: $pin.find('a.pinImageWrapper').prop('href')
              id: hashFromString($pin.find('a.pinImageWrapper').prop('href'))
            })
          processingThisBoard.resolve()

        iframe.on 'load', () ->
          # Don't fully understand, but ajaxComplete seems to only work if use the jquery from the inner window 
          # (see untested answer on http://stackoverflow.com/questions/14563041/detect-content-of-iframe-change-the-content-is-dynamic-jquery-mobile) 
          this.parent.getIframeWindow(this).jQuery(this.parent.getIframeWindow(this).document).ajaxComplete (event, xhr, settings) ->
            return if alreadyProcessingBoard
            iframeAjaxSeen_Categories = true if /resource\/CategoriesResource\/get/.test(settings.url)
            iframeAjaxSeen_Board      = true if /resource\/BoardFeedResource\/get/.test(settings.url)

            # TODO: how handle if too many pins in board, pagination required?
            if (iframeAjaxSeen_Categories && iframeAjaxSeen_Board)
              alreadyProcessingBoard = true
              setTimeout(processSingleBoard, 100)
