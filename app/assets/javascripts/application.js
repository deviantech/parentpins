var Global = Global || {};

$(document).ready(function() {  
  // Handle ajax/modals
  $ajax = $('<div id="ajax-modal-target"></div>').appendTo($('body'));

  $('.ajax').click(function(e) {
    var url = $(this).attr('href');
    
    $ajax.html('<div class="ajax-loader"><img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/></div>').fadeIn();
    url = url + (url.match(/\?/) ? '&' : '?') + 'via_ajax=true';
    $ajax.load(url);
    e.preventDefault();
  });

  function closeModal() {
    $('#ajax-modal-target:visible').fadeOut(function() {
      $(this).empty().show();
    });
  }
    
  // Only close overlay if click was ON overlay, not just bubbled up to it
  $('.pinly_overlay').click(function(e) {
    if ($(e.target).hasClass('pinly_overlay')) closeModal();
  });
  
  $(document).keyup(function(e) {   // Escape key
    if (e.keyCode == 27) { closeModal(); }
  });

  
  // Masonry layout a la pinterest
  $('#pins').masonry({
     columnWidth: 50,
     itemSelector: '.pin'
  }).imagesLoaded(function() {
     $('#pins').masonry('reload');
  });
  
  // Like/Unlike
  $('.like_button').click(function(e) {
    $(this).siblings('.like_button.hidden').removeClass('hidden');
    $(this).addClass('hidden');
    $.post($(this).attr('href'));
    e.preventDefault();
  });
  
  // Comment Button
  $('.comment_button').click(function(e) {
    $this = $(this);
    var focusable;
    
    if ($this.parents('.pinly_overlay').length) {
      focusable = $this.parents('.pinly_overlay').find('.comment_form textarea').first();
      $this.parents('.pinly_overlay').scrollTo(focusable);
    } else {
      focusable = $this.parents('li.pin').find('.comment textarea').first();
      $.scrollTo( $this.parents('li.pin') );
    }
    focusable.focus();
    e.preventDefault();
  });
  
  // Infinite scrolling
  $.ias({
    container: '#pins',
    item: '.pin',
    pagination: '#loadMoreBtn',
    next: '#loadMoreBtn',
    noneleft: '<li class="pagination-none-left">No more to show.</li>',
    loader: '/assets/ui/loader.gif',
    tresholdMargin: -200,
    beforePageChange: function(scrollOffset, nextPageUrl) { console.log("The user wants to go to the next page: "+nextPageUrl); return true; },
    onLoadItems: function(items) {
      // hide new items while they are loading, wait for images to load, then show and update masonry
      var $newElems = $(items).show().css({ opacity: 0 });
      $newElems.imagesLoaded(function(){
        $newElems.animate({ opacity: 1 });
        $('#pins').masonry('appended', $newElems, true);
      });
      return true;
    }
  });
  
  // Implement category selects
  $('.cat_select').each(function(idx, select){
    select = $(select);
    select.on('change', function() {
      var url = select.data('baseUrl');
      if (!url) {
        alert('category_select not yet implemented');
        return;
      }
      if (select.val().length) {
        url += url.indexOf('?') == -1 ? '?' : '&';
        url += select.data('filterName') + '=' + select.val();
      }
      window.location = url;
    });
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