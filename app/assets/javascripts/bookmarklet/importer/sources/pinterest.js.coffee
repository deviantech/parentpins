window.ppImporterClasses ?= {}
window.ppImporterClasses.Sources ?= {}

class window.ppImporterClasses.Sources.Pinterest

  # Global class config
  outputDiv         = $('#ppBookmarkletContent')
  progressDiv       = outputDiv.find('#noPotentialImages')
  appendTarget      = outputDiv
  maxPinConnections    = 5
  
  # Data selectors
  boardSelector = '.boardLinkWrapper'
  pinSelector   = '.pinWrapper'
  
  # TODO: shared with interactivity... also, why needed when updating div contents?
  toggleWindowRepaint = () ->
    body = $('body').first()
    curHeight = body.height()
    body.height(curHeight - 1).height(curHeight)
  
  # Clean up after ourselves when bookmarklet closes
  bookmarkletClosing: () ->
    outputDiv.find('iframe.ppBoardDetailFrame').remove()
  
  constructor: (@parent) ->
    @boardsData = []
    @pinsData = []    
    @boardDetailFrame = null
    @boardQueue = []
    @pinURLsToProcess = []
    


  # If logged in, you can import your own. You can also import another user's if you're on their boards page specifically.
  checkIfCanGetData: () ->
    seemsLegit = true
    
    showError = (msg) ->
      progressDiv.addClass('red').html(msg)
      toggleWindowRepaint()
      seemsLegit = false
    
    if !P?.currentUser
      showError "You'll need to log into pinterest to import your pins."
    else if !P.currentUser.attributes?.username
      showError "It appears the Pinterest API has changed -- please contact us so we can investigate further!"
    else
      # TODO -- sometimes OWN profile has the thing we thought was only for others
      
      # startURLs = if $('.userStats li:first a').length # Other user's profile
      #   name = $('meta[name="og:title"], meta[property="og:title"]').attr('content') || window.location.pathname.split('/')[1]
      #   @parent.Interactivity.setHeader "Importing boards and pins from: #{name}"
      #   [$('.userStats li:first a').attr('href')]
      # else
      #   @parent.Interactivity.setHeader "Importing boards and pins from your Pinterest account (#{P.currentUser.attributes.username})"
      #   ["/#{P.currentUser.attributes.username}/boards/", "/#{P.currentUser.attributes.username}/"]
      # 
      # onStartPage = () ->
      #   (return true if thisURL == window.location.pathname) for thisURL in startURLs
      #   return false
      # 
      # console.log "Given #{startURLs[0]} and #{startURLs[1]}, and currently on #{window.location.pathname}, we say: #{onStartPage()}"
      # 
      # unless onStartPage()
      #   showError "To import your Pinterest pins, please run this bookmarklet from <a href='#{startURLs[0]}'>your Pinterest Boards page</a>."
        
    return seemsLegit

  getData: (callback) ->
    @processingAllBoards = new $.Deferred()
    @processingAllPins = new $.Deferred()

    # Once collected all data, pass it along to the callback function
    @processingAllPins.done () =>
      @reportProgress('Done processing. Passing data over to our servers...')
      progressDiv.hide()
      callback({boards: @boardsData, pins: @pinsData})

    @processingAllBoards.done () =>
      # Clean up the iframe
      @boardDetailFrame.remove()
      @boardDetailFrame = null
      
      # Now start working on the pins
      @pinURLsToProcess = @pinsData.map (pin) -> pin.pinterestURL
      @reportProgress "Done collecting boards.  Now processing pins (#{@pinURLsToProcess.length} remaining)."
      @startProcessingPins()


    # Now start actually getting data
    if $(boardSelector).length then @processBoards() else
      @reportProgress "No boards found!", 'red'    

    
  reportProgress: (message, color) ->
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

  pinForURL: (url) ->
    for pin in @pinsData
      return pin if pin.pinterestURL == url
    return null

  # ===================
  # = Processing Pins =
  # ===================
  startProcessingPins: () ->    
    processOnePin = () =>
      thisURL = @pinURLsToProcess.pop()
      srcPin = @pinForURL(thisURL)
      
      if !(thisURL && srcPin)
        @processingAllPins.resolve()
      else
        # Note: if can get pin URL, could skip ajax entirely. Can get big image name from small one by changing URL (/236x/ -> /736x/): 
        # http://media-cache-ak2.pinimg.com/236x/49/4b/af/494bafca94dd0e2168fb4c8c7f914c78.jpg -> http://media-cache-ak2.pinimg.com/736x/49/4b/af/494bafca94dd0e2168fb4c8c7f914c78.jpg      
        @reportProgress "Done collecting boards.  Now processing pins (#{@pinURLsToProcess.length} remaining)."
        pinRequest = $.get thisURL
        pinRequest.done (pinHTML) =>
          pinHTML       = $(pinHTML)
          srcPin.url       = pinHTML.find('.detailed.Pin.Module .pinWrapper a:first').prop('href')
          srcPin.imageURL  = pinHTML.find('.detailed.Pin.Module .pinWrapper img.pinImage:first').prop('src')          

          # Sometimes it may not have been lazy loaded yet, but we can fill in based on big filename
          if !srcPin.smallImageURL && srcPin.imageURL.match('/736x/')
            srcPin.smallImageURL = srcPin.imageURL.replace('/736x/', '/236x/')
            
        pinRequest.fail =>
          # TODO: do something here to indicate the failure and remove from array, so we don't rely on incomplete data down the road?
        pinRequest.always () =>
          processOnePin()  
    
    for i in [1..maxPinConnections]
      processOnePin()

  # =====================
  # = Processing Boards =
  # =====================
  processBoards: () ->
    @boardQueue = $.makeArray $(boardSelector)
    @boardDetailFrame ?= $('<iframe class="ppBoardDetailFrame">').appendTo( appendTarget ).css({position: 'absolute', top: '-100px', left: '-1000px', height: '50px', width: '50px', visibility: 'hidden'})
    @processAnotherBoard()
  
  # To avoid overwhelming either the browser or the server, we load the boards sequentially
  processAnotherBoard: () ->    
    board         = $( @boardQueue.pop() )
    boardURL      = board.prop('href')
    boardName     = $.trim( board.find('.boardName').text().replace(/^\s*Secret Board\s*/i, '') )
    boardID       = @hashFromString(boardURL)
    expectedPins  = parseInt board.find('.boardPinCount').text().replace(/pins?/, ''), 10

    boardMsg = "Processing Board: #{boardName} (#{@boardQueue.length + 1} remaining)"
    @reportProgress "#{boardMsg}. Discovered <span class='counter'>0</span> of #{expectedPins} pins."

    frameDoc = null
    processingThisBoard = new $.Deferred()

    processingThisBoard.done () =>
      @boardsData.push({name: boardName, pinterestURL: boardURL, id: boardID, numPins: expectedPins})
      if @boardQueue.length == 0 then @processingAllBoards.resolve() else @processAnotherBoard()

    processBoardDetails = () =>      
      $(pinSelector, frameDoc).each (pidx, pin) =>
        pin = $(pin)
        pinData = {
          board_id:       boardID,
          description:    pin.find('.pinDescription').text(),
          domain:         pin.find('.pinDomain').text(),
          price:          pin.find('.priceValue').text(),
          smallImageURL:  pin.find('.pinImg.loaded').prop('src'), # May not be lazy loaded yet
          pinterestURL:   pin.find('a.pinImageWrapper').prop('href')
        }
        pinData.id = @hashFromString "#{boardID}:#{pinData.pinterestURL}"
        if pinData.pinterestURL.length > 4
          @pinsData.push pinData
      processingThisBoard.resolve()

    if expectedPins == 0
      processingThisBoard.resolve()
    else      
      @boardDetailFrame.off 'load' # Remove any previous listeners

      # After load, wait for various ajax events to finish
      @boardDetailFrame.on 'load', () =>
        frameDoc = @boardDetailFrame.contents()
    
        if isNaN(expectedPins)
          console.log "Unable to parse number of expected pins for board (#{boardName}), so waiting two seconds and hoping for the best"
          setTimeout processBoardDetails, 3000
        else
          timeout = 15 * 1000
          foundAllPins = null
          seenLastIteration = 0
          prettyDisplay = null
          
          scrollCounterTo = (max) ->
            clearInterval(prettyDisplay)
            updateCounter = () ->
              if asString = progressDiv.find('.counter').text()
                displayedSeen = parseInt asString, 10
                if !isNaN(displayedSeen) && displayedSeen < max
                  progressDiv.find('.counter').text(displayedSeen + 1)
                else
                  clearInterval updateCounter
            prettyDisplay = setInterval updateCounter, 40
                    
          periodicCheck = () =>
            seen = frameDoc.find('.Pin.Module').length
            if expectedPins == seen
              foundAllPins = true
              clearInterval(pinCountChecker)
              clearInterval(prettyDisplay)
              processBoardDetails()
            else if seen > 0 # Page requires scrolling to spur loading additional pins
              frameDoc.scrollTop( frameDoc.height() )
              
              if seenLastIteration != seen
                @reportProgress "#{boardMsg}. Discovered <span class='counter'>#{seenLastIteration}</span> of #{expectedPins} pins."
                seenLastIteration = seen
                scrollCounterTo(seen)
      
          pinCountChecker = setInterval periodicCheck, 500
      
          timeOutIfRequired = () ->
            unless foundAllPins
              clearInterval(pinCountChecker)
              console.log "Board (#{boardName}) timed out trying to load all pins"
              processBoardDetails() # Will fail to find all pins, but can at least work with what we have
              # TODO: somehow indicate to user that some pins weren't collected
      
          setTimeout timeOutIfRequired, timeout
      
      # Now that listeners are in place, update the frame SRC
      @boardDetailFrame.attr('src', boardURL)
  
  
  # FUTURE: extracted general form out, but isn't yet used
  waitFor: (checkFn, successFn, failFn, interval, timeout) ->
    succeeded = false
    
    periodicCheck = () ->
      if checkFn()
        succeeded = true
        clearInterval(checker)
        successFn()
        
    timeoutIfRequred = () ->
      if !succeeded
        failFn && failFn()
    
    checker = setInterval periodicCheck, interval
    setTimeout timeoutIfRequred, timeout