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
  
  applyTruncationTo('.pin-context .description', 200);
  
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
    
  // Pins comment Button (in page or in modal)
  $(document).on('click', '.comment_button', function(e) {
    $this = $(this);
    if ($this.parents('.pin-context').length == 0) return;
    var focusable;
          
    if ($this.parents('.modal_overlay').length) { // If in modal
      focusable = $this.parents('.modal_overlay').find('.comment_form textarea').first();
      $this.parents('.modal_overlay').scrollTo(focusable);
    } else {
      focusable = $this.parents('li.pin').find('.comment textarea').first();
      focusable.parents('.comment').toggle();
      focusable.parents('.masonry').masonry('reload');
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
  
  // Automatically pop up popup window links
  $(document).on('click', '.js-new-window-popup', function(e) {
    e.preventDefault();
    var link = $(this);
    if (link[0].tagName != 'A') link = link.parents('a');
    
    var newPopupWindow = window.open(link.attr('href'), 'newPopupWindow', "menubar=no,status=no,toolbar=no,location=no,width="+link.data('width')+",height="+link.data('height'));
    if (window.focus) newPopupWindow.focus();
  });
  
  // Add custom trucation
  $(document).on('click', 'a.view-more', function(e) {
    e.preventDefault();
    var wrapper = $(e.target).parent();
    if (wrapper.data('original-text')) {
      if (!wrapper.data('short-text')) wrapper.data('short-text', wrapper.html());
      var longer = wrapper.data('original-text') + ' ' + '<a href="#" class="view-less">(less)</a>';
      wrapper.html(longer);
      wrapper.parents('.masonry').masonry('reload');
    }
  });

  $(document).on('click', 'a.view-less', function(e) {
    e.preventDefault();
    var wrapper = $(e.target).parent();
    if (wrapper.data('short-text')) {
      wrapper.html( wrapper.data('short-text') );
      $.scrollTo(wrapper.parents('.masonry-brick'));
      wrapper.parents('.masonry').masonry('reload');
    }
  });
  
});