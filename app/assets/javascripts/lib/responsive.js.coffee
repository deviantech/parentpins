setSizes = () ->
  w = $(window).width()
  
  # TODO - replace character-based truncation with line-based
  if w <= 320
    applyTruncationTo('li.pin .description span.truncate-me', 40);
  else if w <= 480
    applyTruncationTo('li.pin .description span.truncate-me', 60);
  else
    applyTruncationTo('li.pin .description span.truncate-me', 120);

  
  
setSizes()
$(document).ready () ->
  setSizes()