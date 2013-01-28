$(document).ready(function() {  
  var scroll_timer;
  var displayed = false;
  var $message = $('#scroll_to_top a');
  var $window = $(window);
  var top = $(document.body).children(0).position().top;

  $window.scroll(function () {
    window.clearTimeout(scroll_timer);
    scroll_timer = window.setTimeout(function () { // use a timer for performance
      // hide if at the top of the page
      if ($window.scrollTop() <= top) {
        displayed = false;
        $message.fadeOut(500);
      } else if (displayed == false) { // show if scrolling down
        displayed = true;
        $message.stop(true, true).show().click(function() { 
          $message.fadeOut(500); 
        });
      }
    }, 100);
  });
});