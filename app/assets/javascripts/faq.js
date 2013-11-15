//= require contrib/highlight

hljs.initHighlightingOnLoad();

var wrapper = $('#faq_nav_wrapper');
var spybar = $('ul.spy_navbar');

// Keep ul as narrow as the wrapper that would be containing it without the affix-ness
function rebindWidth() {
  spybar.width( wrapper.width() );
}

if ($(window).width() >= 770){	
  rebindWidth();
	spybar.affix({offset: {top: wrapper.offset().top - 10, bottom: 200}});
  $(window).resize(rebindWidth);
}
