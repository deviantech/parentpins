// Configurable
Global.loadNextPageIfBelow = 300; 
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
  
  paginationButton.on('click', function(e) {
    e.preventDefault();
    loadNextPage();
  });
  
  function loadNextPage() {
    if (ajaxDonePaginating) {
      console.log('ajaxDonePaginating');
      return;
    }
  
    var $resultsHolder = $('ul.ajax-pagination');
    var $btn = paginationButton;
  
    $btn.fadeOut();
    $('.loader_icon').hide(); // If any were animating nicely, just get rid of them
    var $paginationLoader = $('<img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/>').hide().insertAfter($btn).fadeIn();

    if (nextAjaxPage) {
      nextAjaxPage = nextAjaxPage + 1;
    } else {
      nextAjaxPage = $btn.data('next-page') ? parseInt($btn.data('next-page'), 10) : 1;
    }
    console.log('Next page: '+urlPossiblyReplacingParam($btn.attr('href'), 'page', nextAjaxPage));

    lastPaginationAjax = $.ajax({
      url: urlPossiblyReplacingParam($btn.attr('href'), 'page', nextAjaxPage),
      headers: { 
        "Accept": "ajax/pagination",
        "Content-Type": "ajax/pagination"
      },
      success: insertNewPage,
      complete: function(jqxhr) {
        console.log('completed');
        if (jqxhr == lastPaginationAjax) $paginationLoader.fadeOut();
      }
    });
  
    function insertNewPage(items, status, jqxhr) {
      console.log('success');
      
      // hide new items while they are loading, wait for images to load, then show and update masonry
      var $newItems = $(items).hide();
      $resultsHolder.append($newItems);

      // If none shown, hide button
      if ($newItems.length) {
        if (!Global.useInfinitePagination) $btn.fadeIn();
      } else {
        ajaxDonePaginating = true;
      
        // Show no results div
        $('<div class="empty-results">No more to show.</div>').hide().insertAfter($resultsHolder).fadeIn();
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
  
  function considerInfiniteScrolling() {
    if (currentlyConsidering || ajaxDonePaginating) return;

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
