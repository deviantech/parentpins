//= require templates/bookmarklet/pinterest/results

# Note - maybe if eval in getScript (or just $.get callback, can pass in vars from other script?)

# Config
outputDiv = $('#ppBookmarkletContent')
progressDiv = outputDiv.find('#noPotentialImages') # TODO -- pass this in in case there's another with this ID in the original page's HTML
boardSelector = '.UserBoards .item.gridSortable a.boardLinkWrapper'
pinSelector   = '.pinWrapper'
debug = true

processingAllBoards = new $.Deferred()
processingAllPins = new $.Deferred()
boardsData = []
boardsPending = $(boardSelector).length
pinsPending = 'unknown'

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
  window.data = boardsData
  
  # Calculate how many to do
  pinsPending = 0
  for board in boardsData
    pinsPending += board.pins.length
  reportProgress('beginning to process pins')
  
  # Now start doing them
  for board in boardsData
    processThisPin(pin) for pin in board.pins
  
processingAllPins.done () ->
  outputDiv.html( JST['templates/bookmarklet/pinterest/results']({boards: boardsData}) )
  window.data = boardsData


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
    pin.link = this.contentWindow.jQuery('.detailed.Pin.Module .pinWrapper a').first().prop('href')
    pin.imageURL = this.contentWindow.jQuery('.detailed.Pin.Module .pinWrapper img.pinImage').first().prop('src')
    finalizedAPin(pin)
    



$(boardSelector).each (bidx, board) ->
  processingThisBoard = new $.Deferred()
  $board = $(board)
  boardURL = $board.prop('href')
  boardName = $.trim( $board.find('.boardName').text() )
  boardPinData = []

  iframeAjaxSeen_Categories = false
  iframeAjaxSeen_Board = false
  alreadyProcessingBoard = false

  iframe = $('<iframe>').hide().attr('src', boardURL).appendTo( $('body') ).show().css({position: 'absolute', left: '50px', top: (bidx*500)+'px', height: '500px', width: '500px', border: '2px solid #333', 'z-index': 9999999999999})

  processingThisBoard.done () ->
    boardsPending -= 1
    boardsData.push({
      name: boardName,
      pinterestURL: boardURL,
      pins: boardPinData
    })
    reportProgress('finished processing board: '+boardName)
    processingAllBoards.resolve() if boardsPending == 0
    
  processSingleBoard = () ->
    $ = iframe.get(0).contentWindow.jQuery
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
      })
    processingThisBoard.resolve()
    
  iframe.on 'load', () ->
    # Don't fully understand, but ajaxComplete seems to only work if use the jquery from the inner window 
    # (see untested answer on http://stackoverflow.com/questions/14563041/detect-content-of-iframe-change-the-content-is-dynamic-jquery-mobile) 
    this.contentWindow.jQuery(this.contentWindow.document).ajaxComplete (event, xhr, settings) ->
      return if alreadyProcessingBoard
      iframeAjaxSeen_Categories = true if /resource\/CategoriesResource\/get/.test(settings.url)
      iframeAjaxSeen_Board      = true if /resource\/BoardFeedResource\/get/.test(settings.url)
      
      # TODO: how handle if too many pins in board, pagination required?
      if (iframeAjaxSeen_Categories && iframeAjaxSeen_Board)
        alreadyProcessingBoard = true
        setTimeout(processSingleBoard, 100)
