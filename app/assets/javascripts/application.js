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

