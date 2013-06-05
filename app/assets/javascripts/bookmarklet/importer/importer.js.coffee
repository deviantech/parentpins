window.ppImportClasses ?= {}

window.ppImportClasses.ImporterBase = (opts) ->
  @options = opts
  @DataImporter = window.ppImportClasses.GetData(this)
  @Interactivity = window.ppImportClasses.Interactivity(this)
  
  @boardsData = @DataImporter.getData()
  
  # Workaround for non-supporting browsers
  @getIframeWindow = (iframeElement) ->
    iframeElement.contentWindow || iframeElement.contentDocument.parentWindow

  # Pass bookmarkletClosing on to interior classes
  @bookmarkletClosing = () ->
    @DataImporter.bookmarkletClosing && @DataImporter.bookmarkletClosing()
    @Interactivity.bookmarkletClosing && @Interactivity.bookmarkletClosing()