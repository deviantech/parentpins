var Global = Global || {};

$(document).ready(function() {  
  // Handle ajax/modals
  $ajax = $('<div id="ajax-modal-target"></div>').appendTo($('body'));

  $(document).on('click', '.ajax', function(e) {
    var url = $(this).attr('href');
    $ajax.html('<div class="ajax-loader"><img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/></div>').fadeIn();
    
    url = urlPlusParamString(url, 'via=ajax');
    $ajax.load(url);
    e.preventDefault();
    e.stopPropagation();
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
    
    $(this).parent().find('.following-action').each(function() {
      if ($(this).hasClass('hidden')) {
        $(this).removeClass('hidden');
      } else {
        $(this).addClass('hidden');
      }
    });
  });
    
  // Set filters
  $('.set_filters').on('change', function(e) {
    $select = $(e.target);
    
    if ($select.data('base-url-if-blank')) {
      // Adding support to handle pretty URLs, e.g. /pins if not kind set, but /products if kind is 'product'
      var baseURL;
      if ($select.val()) {
        baseURL = '/' + $select.val() + 's';
      } else {
        baseURL = $select.data('base-url-if-blank');
      }
      window.location = urlReplacingPathKeepingParams(baseURL);
    } else {
      // Normal, update URL components but don't worry about base URL changing
      window.location = urlPossiblyReplacingParam(window.location + '', $select.attr('name'), $select.val());
    }
  });
});

function updateProfileCounters(data) {
  for (var key in data) {
    var target = $('.nav_profile a.'+key);
    if (target.length) {
      target.find('.counter').html(data[key]);
      var label = capitalize(key);
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