var Global = Global || {};

$(document).ready(function() {  
  // Handle ajax/modals
  $ajax = $('<div id="ajax-modal-target"></div>').appendTo($('body'));

  $('.ajax').click(function(e) {
    var url = $(this).attr('href');
    
    $ajax.html('<div class="ajax-loader"><img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/></div>').fadeIn();
    url = urlPlusParamString(url, 'via=ajax');
    $ajax.load(url);
    e.preventDefault();
  });

  function closeModal() {
    $('#ajax-modal-target:visible').fadeOut(function() {
      $(this).empty().show();
    });
  }
    
  // Only close overlay if click was ON overlay, not just bubbled up to it
  $(document).on('click', '.pinly_overlay', function(e) {
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
  
  // Pin actions
  function getContainingClassNameForPinAction(btn) {
    var classList;
    if ($(btn).parents('.pinly').length) { // Clicked in Pin
      classList = $(btn).parents('.pinly').attr('class');
    } else {
      classList = $(btn).parents('li').attr('class');
    }
    var matched = classList.match(/pin_(\d+)/);
    return matched ? matched[0] : null;
  }
  
  // Like/Unlike
  $(document).on('click', '.like_button', function(e) {
    var url = urlPlusParamString($(this).data('url'), 'context=' + $('.nav_profile').data('profileId'));
    $.post(url);
    e.preventDefault();
    e.stopPropagation();
    
    // Update any other pins on the page, too
    var cssClass = getContainingClassNameForPinAction(this);
    $('.'+cssClass).find('.like_button').each(function() {
      if ($(this).hasClass('hidden')) {
        $(this).removeClass('hidden');
      } else {
        $(this).addClass('hidden');
      }
    });
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
    e.stopPropagation();
  });
  
  // Follow/unfollow buttons
  $(document).on('click', '.following-action', function(e) {
    var url = urlPlusParamString($(this).data('url'), 'context=' + $('.nav_profile').data('profileId'));
    $.post(url);
    e.preventDefault();
    e.stopPropagation();
    
    var cssClass = $(this).parent().attr('class');
    $('.'+cssClass).find('.following-action').each(function() {
      if ($(this).hasClass('hidden')) {
        $(this).removeClass('hidden');
      } else {
        $(this).addClass('hidden');
      }
    });
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

function updateProfileCounters(data) {
  for (var key in data) {
    var target = $('.nav_profile a.'+key);
    if (target.length) {
      target.find('.counter').html(data[key]);
      var label = key.substr(0,1).toUpperCase() + key.substr(1);            
      if (key != 'following') {
        if (data[key] == 1) {
          if (label.substr(label.length-1, 1) == 's') label = label.substr(0, label.length - 1);
        } else {
          if (label.substr(label.length-1, 1) != 's') label = label + 's';
        }
      }
      target.find('.label').html(label);
    }
  }
}

function urlPlusParamString(url, params) {
  return url + (url.match(/\?/) ? '&' : '?') + params;
}

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