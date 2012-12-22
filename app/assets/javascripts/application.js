$(document).ready(function() {
  $('.pinly_toggle').click(function(){
	//get collapse content selector
	var collapse_content_selector = $(this).attr('href');					

	//make the collapse content to be shown or hide
	var toggle_switch = $(this);
	$(collapse_content_selector).toggle(function(){
	  if($(this).css('display')=='none'){
                            //change the button label to be 'Show'
		toggle_switch.html('Show');
	  }else{
                            //change the button label to be 'Hide'
		toggle_switch.html('Hide');
	  }
	});
  });

});	

$(document).ready(function() {
  $('#pins').masonry({
   columnWidth: 50,
   itemSelector: '.pin'
  }).imagesLoaded(function() {
   $('#pins').masonry('reload');
  });
});

$(function () { // run this code on page load (AKA DOM load)
  
    /* set variables locally for increased performance */
    var scroll_timer;
    var displayed = false;
    var $message = $('#scroll_to_top a');
    var $window = $(window);
    var top = $(document.body).children(0).position().top;
  
    /* react to scroll event on window */
    $window.scroll(function () {
        window.clearTimeout(scroll_timer);
        scroll_timer = window.setTimeout(function () { // use a timer for performance
            if($window.scrollTop() <= top) // hide if at the top of the page
            {
                displayed = false;
                $message.fadeOut(500);
            }
            else if(displayed == false) // show if scrolling down
            {
                displayed = true;
                $message.stop(true, true).show().click(function () { $message.fadeOut(500); });
            }
        }, 100);
    });
});
