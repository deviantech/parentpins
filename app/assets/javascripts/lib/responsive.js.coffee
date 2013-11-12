setSizes = () ->
  w = $(window).width()
  
  # TODO - replace character-based truncation with line-based
  if w <= 320
    applyTruncationTo('li.pin .description span.truncate-me', 40);
    applyTruncationTo('li.pin .comment .details', 40);
  else if w <= 480
    applyTruncationTo('li.pin .description span.truncate-me', 60);
    applyTruncationTo('li.pin .comment .details', 60);
  else
    applyTruncationTo('li.pin .description span.truncate-me', 120);
    applyTruncationTo('li.pin .comment .details', 200);
    
  nav = $('.profile ul.nav_profile')
  if nav.length
    nav.width(nav.find('li').first().width() * 7)


  
  

$(document).ready () ->
  setSizes()
  
$(window).on 'resize', setSizes