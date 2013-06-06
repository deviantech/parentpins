window.sendMessage = (msg, explanation) ->
  if (!window.parent)
    if explanation then alert("Sorry, can't " + explanation + " because page doesn't appear to have been loaded in a bookmarklet context.")
  else if (!window.parent.postMessage)
    if explanation then alert("Sorry, can't " + explanation + " because your browser appears to old to support modern web standards.")
  else
    window.parent.postMessage(msg, '*')
