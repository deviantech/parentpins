// Actual application code goes here

$(document).ready(function() {
  $('#pins').masonry({
   columnWidth: 50,
   itemSelector: '.pin'
  }).imagesLoaded(function() {
   $('#pins').masonry('reload');
  });
});
