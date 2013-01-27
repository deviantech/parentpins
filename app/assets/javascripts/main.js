$(document).ready(function() {      
  // Masonry layout a la pinterest
  $('.masonry').masonry({
     columnWidth: 50,
     itemSelector: '.pin',
     isAnimatedFromBottom: true,
     isFitWidth: true
  }).imagesLoaded(function() {
     $('.masonry').masonry('reload');
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
    
    if ($this.parents('.modal_overlay').length) {
      focusable = $this.parents('.modal_overlay').find('.comment_form textarea').first();
      $this.parents('.modal_overlay').scrollTo(focusable);
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