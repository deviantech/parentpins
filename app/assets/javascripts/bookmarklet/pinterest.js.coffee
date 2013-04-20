//= require templates/bookmarklet/pinterest/results

# Note - maybe if eval in getScript (or just $.get callback, can pass in vars from other script?)

# Config
outputDiv = $('#ppBookmarkletContent')
progressDiv = outputDiv.find('#noPotentialImages') # TODO -- pass this in in case there's another with this ID in the original page's HTML
boardSelector = '.UserBoards .item.gridSortable a.boardLinkWrapper'
pinSelector   = '.pinWrapper'
debug = false
useTestData = true

testData = [{"name":"Default","pinterestURL":"http://pinterest.com/dvntpins/default/","pins":[{"description":"Brandy Melville Tank $28","domain":"saltandseaweed.com","price":"$28.00","smallImageURL":"http://media-cache-ak1.pinimg.com/236x/06/49/09/06490959f16ea755c89e3b444a9e5686.jpg","pinterestURL":"http://pinterest.com/pin/442126888388601214/","link":"http://www.saltandseaweed.com/collections/vendors?q=Brandy+Melville","imageURL":"http://media-cache-ak1.pinimg.com/736x/06/49/09/06490959f16ea755c89e3b444a9e5686.jpg"},{"description":"That's How a Pro Uses a Bunk Bed","domain":"memebase.cheezburger.com","price":"","smallImageURL":"http://media-cache-ak1.pinimg.com/236x/6e/06/34/6e063495136bfc91b8cfac6cd55e8557.jpg","pinterestURL":"http://pinterest.com/pin/442126888388218505/","link":"http://memebase.cheezburger.com/senorgif","imageURL":"http://media-cache-ak1.pinimg.com/736x/6e/06/34/6e063495136bfc91b8cfac6cd55e8557.jpg"},{"description":"ireland - Google Search","domain":"travel.nytimes.com","price":"","smallImageURL":"http://media-cache-ak1.pinimg.com/236x/49/4b/af/494bafca94dd0e2168fb4c8c7f914c78.jpg","pinterestURL":"http://pinterest.com/pin/442126888388183279/","link":"http://travel.nytimes.com/travel/guides/europe/ireland/overview.html","imageURL":"http://media-cache-ak1.pinimg.com/736x/49/4b/af/494bafca94dd0e2168fb4c8c7f914c78.jpg"}]}]

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
    


if useTestData
  boardsData = testData
  processingAllPins.resolve()
else
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
