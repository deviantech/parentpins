// Configurable
Global.loadNextPageIfCloseThan = 300; 
Global.useInfinitePagination = true;

$(document).ready(function() {
  if ($('.ajax-pagination').length && $('.load_more_button').length) {
    if (Global.useInfinitePagination) $('.load_more_button').hide(); // If no JS, show as fallback. If JS, not needed
    initAjaxPagination( $('.load_more_button') );
  }
});
 
function initAjaxPagination(paginationButton) {
  var nextAjaxPage = null;
  var ajaxDonePaginating = false;
  var lastPaginationAjax = null;
  var currentlyConsidering = false;

  var $doc = $(document);  
  var $resultsHolder = $('ul.ajax-pagination');
  var $btn = paginationButton;
  
  paginationButton.on('click', function(e) {
    e.preventDefault();
    loadNextPage();
  });
  
  function loadNextPage() {
    if (ajaxDonePaginating) {
      return;
    }
  
    $btn.fadeOut();
    $('.loader_icon').hide(); // If any were animating nicely, just get rid of them
    var $paginationLoader = $('<img src="/assets/ui/loader.gif" alt="Loading" class="loader_icon"/>').hide().insertAfter($btn).fadeIn();

    if (nextAjaxPage) {
      nextAjaxPage = nextAjaxPage + 1;
    } else {
      nextAjaxPage = $btn.data('next-page') ? parseInt($btn.data('next-page'), 10) : 1;
    }

    lastPaginationAjax = $.ajax({
      url: urlPossiblyReplacingParam($btn.attr('href'), 'page', nextAjaxPage),
      headers: { 
        "Accept": "ajax/pagination",
        "Content-Type": "ajax/pagination"
      },
      success: insertNewPage,
      complete: function(jqxhr) {
        if (jqxhr == lastPaginationAjax) $paginationLoader.fadeOut();
      }
    });
  
    function insertNewPage(items, status, jqxhr) {
      // hide new items while they are loading, wait for images to load, then show and update masonry
      var $newItems = $(items).hide();
      $resultsHolder.append($newItems);

      // If none shown, hide button
      if ($newItems.length) {
        if (!Global.useInfinitePagination) $btn.fadeIn();
      } else {
        ajaxDonePaginating = true;
      
        // Show no results div
        $('<div class="clearfix"></div><div class="empty-results">No more to show.</div>').hide().insertAfter($resultsHolder).fadeIn();
      }

      // Now actually show the results
      $newItems.imagesLoaded(function(){
        try {
          $newItems.fadeIn();
        } catch(e) {
          // FireFox throws an exception when trying to animate a hidden node, marked wontfix: http://bugs.jquery.com/ticket/12462
          $newItems.show();
        }
        $resultsHolder.masonry('appended', $newItems, true);
      });
      
      // Allow another load to happen
      if (jqxhr == lastPaginationAjax) currentlyConsidering = false;
      considerInfiniteScrolling();
    }
  
  }

  if (Global.useInfinitePagination) {
    $(window).on('scroll resize', considerInfiniteScrolling);
  }

  // See how much of .ajax-pagination is still below the viewport. If less than Global.loadNextPageIfCloseThan, start loading more
  function considerInfiniteScrolling() {
    if (currentlyConsidering || ajaxDonePaginating) return;
    
    var pageHeight      = $resultsHolder.offset().top + $resultsHolder.height();
    var scrollPos       = $doc.scrollTop();
    var viewportHeight  = $(window).height();
    var remainingDist   = pageHeight - scrollPos - viewportHeight;

    if (remainingDist < Global.loadNextPageIfCloseThan) {
      currentlyConsidering = true;
      loadNextPage( $('.load_more_button') );
    }
  }
  
}
