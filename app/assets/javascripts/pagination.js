// TODO :
// Show 'no more to load' text as necessary
// make infiite scrolling
// better handling of concurrent ajax loads (don't hide loader until all gone, don't show multiple)

Global.nextPinPage = null;
Global.pinsDonePaginating = false;

$('.load_more_button').on('click', function(e) {
  e.preventDefault();
  if (Global.pinsDonePaginating) return;
  
  var $pinHolder = $('#pins');
  var $btn = $(this);
  
  $btn.fadeOut();
  var $paginationLoader = $('<img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/>').hide().insertAfter($btn).fadeIn();

  if (Global.nextPinPage) {
    Global.nextPinPage = Global.nextPinPage + 1;
  } else {
    Global.nextPinPage = $btn.data('next-page') ? parseInt($btn.data('next-page'), 10) : 1;
  }

  $.ajax({
    url: urlPossiblyReplacingParam($btn.attr('href'), 'page', Global.nextPinPage),
    headers: { 
      "Accept": "pin/pagination",
      "Content-Type": "pin/pagination"
    },
    success: insertNewPinPage,
    complete: function() {
      $paginationLoader.fadeOut();
    }
  });
  
  function insertNewPinPage(items) {
    // hide new items while they are loading, wait for images to load, then show and update masonry
    var $newItems = $(items).hide();
    $pinHolder.append($newItems);

    // If none shown, hide button
    if ($newItems.length) {
      $btn.fadeIn();
    } else {
      Global.pinsDonePaginating = true;
      
      // Show no results div
      $('<div class="empty-pins">No more pins to show.</div>').hide().insertAfter($pinHolder).fadeIn();
    }    

    // Now actually show the results
    $newItems.imagesLoaded(function(){
      try {
        $newItems.fadeIn();
      } catch(e) {
        // FireFox throws an exception when trying to animate a hidden node, marked wontfix: http://bugs.jquery.com/ticket/12462
        $newItems.show();
      }
      $('#pins').masonry('appended', $newItems, true);
    });
  }
  
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
  //     var $newItems = $(items).show().css({ opacity: 0 });
  //     $newItems.imagesLoaded(function(){
  //       $newItems.animate({ opacity: 1 });
  //       $('#pins').masonry('appended', $newItems, true);
  //     });
  //     return true;
  //   }
  // });
  
  
});