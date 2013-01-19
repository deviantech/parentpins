//= require templates/bookmarklet



// TODO - how to not mess with calling page's jquery version?
// TODO - how to wrap template includes in our bugger function to protect it from including page's content?


(function(document, jQuery) {
  // Config
  var popupName = 'ParentPinBookmarklet';
  var minJQversion = '1.6.0';
  var desiredJQversion = '1.8.2';
  
	// check prior inclusion and version
	if (window.jQuery === undefined || window.jQuery.fn.jquery < minJQversion) {
		var done = false;
		var script = document.createElement("script");
		script.src = "//ajax.googleapis.com/ajax/libs/jquery/" + desiredJQversion + "/jquery.min.js";
		script.onload = script.onreadystatechange = function(){
			if (!done && (!this.readyState || this.readyState == "loaded" || this.readyState == "complete")) {
				done = true;
				initBookmarkletWrapper();
			}
		};
		document.getElementsByTagName("head")[0].appendChild(script);
	} else {
		initBookmarkletWrapper();
	}
  
  // Just to be sure $ is available and not in compatibility mode on the host site
  function initBookmarkletWrapper() {
    (window.myBookmarklet = function() {
       initBookmarklet(jQuery);
    })();
  }
  
  // Close popup if any are open
  function initBookmarklet($) {
    if ($('#'+popupName).length) {
      $('#'+popupName).fadeOut();
      return;
    }
    
    
    // .pinly_overlay {
    //   background: rgba(255,255,255,0.9);
    //   display: block;
    //   height: 100%;
    //   left: 0;
    //   position: fixed;
    //   top: 0;
    //   width: 100%;
    //   overflow-y:scroll;
    // }
    // 
    // .pinly {
    //   position: static;
    //   width: 500px;
    //   padding: 10px;
    //   margin: 20px auto;
    //   background: #fff;
    //   border-right: 1px solid #ddd;
    //   border-bottom: 1px solid #ddd;
    //   -webkit-box-shadow: 0 0px 9px rgba(0, 10, 10, 0.38);
    //   -moz-box-shadow: 0 0px 9px rgba(0, 10, 10, 0.38);
    //   box-shadow: 0 0px 9px rgba(0, 10, 10, 0.38);
    //   -webkit-transition: all 0.4s ease-in-out;
    //   -moz-transition: all 0.4s ease-in-out;
    //   -o-transition: all 0.4s ease-in-out;
    //   transition: all 0.4s ease-in-out;
    
    var $popup = $('<div id="test">Woot</div>').appendTo( $('body') );
  }
  
})(document, jQuery);