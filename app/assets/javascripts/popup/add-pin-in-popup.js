// Apparently only in the popup, and apparently only in Chrome, if the form loads with longer-than-viewable-without-scrolling content in the text area, overwriting or deleting the text area's default value will make the textbox disappear from view (still present in DOM).  Forcing CSS update on key press repaints the textarea, which seems to work around this issue.
// For reference, see pinning e.g. http://www.flickr.com/photos/heidihope/4831849906/

$(document).ready(function(){
  // Preload img.
  $('<img src="/assets/ui/ball-loader.gif" title="Preload">').hide().appendTo($('body'));
  
  $('textarea').on('keyup', function() {
    // Size is specified in CSS, so this doesn't affect UI
    $(this).attr('cols', $(this).attr('cols')+1);
  });
});

$(document).on('submit', '.pin_form', function() {
  $('.form').children().slideUp(function() {
    $('.form').animate({width: '220px', padding: '10px 0px', 'margin-left': '293px'});
  });
  $('<img src="/assets/ui/ball-loader.gif" class="loading" title="Processing"><br><h3>Processing...</h3>').hide().appendTo('.form').slideDown();
});