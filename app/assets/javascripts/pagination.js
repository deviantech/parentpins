// Configurable
Global.loadNextPageIfBelow = 300; 
Global.useInfinitePagination = true;

$(document).ready(function() {
  if ($('#pins').length && $('.load_more_button').length) {
    if (Global.useInfinitePagination) $('.load_more_button').hide(); // If no JS, show as fallback. If JS, not needed
    initPinPagination( $('.load_more_button') );
  }
});
 
function initPinPagination(paginationButton) {
  var nextPinPage = null;
  var pinsDonePaginating = false;
  var lastPaginationAjax = null;
  var currentlyConsidering = false;
  
  paginationButton.on('click', function(e) {
    e.preventDefault();
    loadNextPage();
  });
  
  function loadNextPage() {
    if (pinsDonePaginating) {
      console.log('pinsDonePaginating');
      return;
    }
  
    var $pinHolder = $('#pins');
    var $btn = paginationButton;
  
    $btn.fadeOut();
    $('.loader_icon').hide(); // If any were animating nicely, just get rid of them
    var $paginationLoader = $('<img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/>').hide().insertAfter($btn).fadeIn();

    if (nextPinPage) {
      nextPinPage = nextPinPage + 1;
    } else {
      nextPinPage = $btn.data('next-page') ? parseInt($btn.data('next-page'), 10) : 1;
    }
    console.log('Next page: '+urlPossiblyReplacingParam($btn.attr('href'), 'page', nextPinPage));

    lastPaginationAjax = $.ajax({
      url: urlPossiblyReplacingParam($btn.attr('href'), 'page', nextPinPage),
      headers: { 
        "Accept": "pin/pagination",
        "Content-Type": "pin/pagination"
      },
      success: insertNewPinPage,
      complete: function(jqxhr) {
        console.log('completed');
        if (jqxhr == lastPaginationAjax) $paginationLoader.fadeOut();
      }
    });
  
    function insertNewPinPage(items, status, jqxhr) {
      console.log('success');
      
      // hide new items while they are loading, wait for images to load, then show and update masonry
      var $newItems = $(items).hide();
      $pinHolder.append($newItems);

      // If none shown, hide button
      if ($newItems.length) {
        if (!Global.useInfinitePagination) $btn.fadeIn();
      } else {
        pinsDonePaginating = true;
      
        // Show no results div
        $('<div class="empty-pins">No more to show.</div>').hide().insertAfter($pinHolder).fadeIn();
      }    

      // Now actually show the results
      $newItems.imagesLoaded(function(){
        try {
          $newItems.fadeIn();
        } catch(e) {
          // FireFox throws an exception when trying to animate a hidden node, marked wontfix: http://bugs.jquery.com/ticket/12462
          $newItems.show();
        }
        $pinHolder.masonry('appended', $newItems, true);
      });
      
      // Allow another load to happen
      if (jqxhr == lastPaginationAjax) currentlyConsidering = false;
    }
  
  }

  if (Global.useInfinitePagination) {
    $(window).on('scroll resize', considerInfiniteScrolling);
  }
  
  function considerInfiniteScrolling() {
    if (currentlyConsidering || pinsDonePaginating) return;

    var $doc = $(document);
    var pageHeight      = $doc.height();
    var scrollPos       = $doc.scrollTop();
    var viewportHeight  = $(window).height();
    var distanceToDocumentBottomBelowViewport = pageHeight - scrollPos - viewportHeight;

    if (distanceToDocumentBottomBelowViewport < Global.loadNextPageIfBelow) {
      currentlyConsidering = true;
      console.log('Loading next page');
      loadNextPage( $('.load_more_button') );
    }
  }
  
}
