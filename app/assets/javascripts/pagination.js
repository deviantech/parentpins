// TODO :
// better handling of concurrent ajax loads (don't hide loader until all gone, don't show multiple)
// make infiite scrolling

Global.nextPinPage = null;

$('.load_more_button').on('click', function(e) {
  e.preventDefault();
  
  var $paginationLoader = $('<img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/>').hide().insertAfter(this).fadeIn();

  if (Global.nextPinPage) {
    Global.nextPinPage = Global.nextPinPage + 1;
  } else {
    Global.nextPinPage = $(this).data('next-page') ? parseInt($(this).data('next-page'), 10) : 1;
  }

  $.ajax({
    url: urlPossiblyReplacingParam(this.href, 'page', Global.nextPinPage),
    headers: { 
      Accept: "pin/pagination",
      "Content-Type": "pin/pagination"
    },
    success: function(items) {
      // hide new items while they are loading, wait for images to load, then show and update masonry
      var $newElems = $(items).hide();
      $('#pins').append($newElems);
      
      $newElems.imagesLoaded(function(){
        try {
          $newElems.fadeIn();
        } catch(e) {
          // FireFox throws an exception when trying to animate a hidden node, marked wontfix: http://bugs.jquery.com/ticket/12462
          $newElems.show();
        }
        $('#pins').masonry('appended', $newElems, true);
      });          
    },
    complete: function() {
      $paginationLoader.fadeOut();
    }
  });
  
});


$(document).ready(function() {
  
  // Infinite scrolling
  // $.ias({
  //   container: '#pins',
  //   item: '.pin',
  //   pagination: '#loadMoreBtn',
  //   next: '#loadMoreBtn',
  //   noneleft: '<li class="pagination-none-left">No more to show.</li>',
  //   loader: '/assets/ui/loader.gif',
  //   tresholdMargin: -200,
  //   beforePageChange: function(scrollOffset, nextPageUrl) { console.log("The user wants to go to the next page: "+nextPageUrl); return true; },
  //   onLoadItems: function(items) {
  //     // hide new items while they are loading, wait for images to load, then show and update masonry
  //     var $newElems = $(items).show().css({ opacity: 0 });
  //     $newElems.imagesLoaded(function(){
  //       $newElems.animate({ opacity: 1 });
  //       $('#pins').masonry('appended', $newElems, true);
  //     });
  //     return true;
  //   }
  // });
  
  
});