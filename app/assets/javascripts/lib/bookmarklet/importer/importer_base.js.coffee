window.ppImporterClasses ?= {}

class window.ppImporterClasses.ImporterBase

  # Workaround for non-supporting browsers
  getIframeWindow: (iframeElement) ->
    iframeElement = $(iframeElement)[0] # Ensure we're working with the DOM object, not the jQuery wrapper
    iframeElement.contentWindow || iframeElement.contentDocument.parentWindow

  # Pass bookmarkletClosing on to interior classes
  bookmarkletClosing: () ->
    @DataImporter.bookmarkletClosing && @DataImporter.bookmarkletClosing()
    @Interactivity.bookmarkletClosing && @Interactivity.bookmarkletClosing()
  
  constructor: (@options) ->
    @DataImporter = new window.ppImporterClasses.GetData(this)
    @Interactivity = new window.ppImporterClasses.Interactivity(this)

    # Start working here (fire off interactivity once data has been processed)...
    if @DataImporter.canGetData()
      @DataImporter.getData (data) =>
        @Interactivity.start(data)
        
