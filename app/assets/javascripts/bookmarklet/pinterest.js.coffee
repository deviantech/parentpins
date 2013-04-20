//= require templates/bookmarklet/pinterest/results

# Note - maybe if eval in getScript (or just $.get callback, can pass in vars from other script?)

# Config
outputDiv = $('#ppBookmarkletContent')
progressDiv = outputDiv.find('#noPotentialImages') # TODO -- pass this in in case there's another with this ID in the original page's HTML
boardSelector = '.UserBoards .item.gridSortable a.boardLinkWrapper'
pinSelector   = '.pinWrapper'

processingAllBoards = new $.Deferred()
boardsData = []
boardsPending = $(boardSelector).length


processingAllBoards.done () ->
  progressDiv.text('Completed all boards!')
  outputDiv.html( JST['templates/bookmarklet/pinterest/results']({boards: boardsData}) )
  window.data = boardsData


reportProgress = () ->
  msg = if boardsPending == 0
    "Completed all boards!"
  else if boardsPending == 1
    "Collecting account information: one board remaining..."
  else
    "Collecting account information: " + boardsPending + ' boards remaining...'
  progressDiv.text(msg)


reportProgress()
$(boardSelector).each (bidx, board) ->
  processingThisBoard = new $.Deferred()
  $board = $(board)
  boardURL = $board.prop('href')
  boardName = $.trim( $board.find('.boardName').text() )
  boardPinData = []

  iframeAjaxSeen_Categories = false
  iframeAjaxSeen_Board = false
  alreadyProcessingBoard = false

  iframe = $('<iframe>').attr('src', boardURL).appendTo( $('body') )
  #.css({position: 'absolute', left: '50px', top: (bidx*h+50)+'px', height: h+'px', width: '500px', border: '2px solid #333', 'z-index': 9999999999999})

  processingThisBoard.done () ->
    boardsPending -= 1
    boardsData.push({
      name: boardName,
      pinterestUrl: boardURL,
      pins: boardPinData
    })
    reportProgress()
    processingAllBoards.resolve() if boardsPending == 0
    
  processSingleBoard = () ->
    iframe.contents().find(pinSelector).each (pidx, pin) ->
      $pin = $(pin)
      boardPinData.push({
        description: $pin.find('.pinDescription').text(),
        domain: $pin.find('.pinDomain').text(),
        pinterestUrl: $pin.find('a.pinImageWrapper').prop('href')
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
