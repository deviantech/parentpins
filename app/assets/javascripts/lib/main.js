$(document).ready(function() {      
  // Masonry layout a la pinterest
  applyMasonry();
  
  // TODO - replace character-based truncation with line-based
  applyTruncationTo('li.pin .description span.truncate-me', 120);
  applyTruncationTo('li.board .description span.truncate-me', 12);
  $('.truncate-me').each(function() {
    var elem = $(this);
    applyTruncationTo(elem, elem.data('max-length'));
  });


  $('[rel=tooltip]').tooltip({container: 'body', trigger: 'hover'});
  $('[rel=popover]').popover({container: 'body', trigger: 'hover'});

  applyCharacterCounterTo('.character_counter');
  
  if ($('.feat_carousel').length) matchAllFeaturedHeights();
  
  var windowHash = window.location.hash || window.originalLocationHash;
  if (windowHash) {
    try {
      var target = $(windowHash);
      if (target.length) scrollTo(target);
    } catch(e) {
      // Possible errors jquery-ing user input. Disregard.
    }
  }
  
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
    var context = $('.nav_profile').length ? ('context=' + $('.nav_profile').data('profileId')) : '';
    var url = urlPlusParamString($(this).data('url'), context);
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
          
    if ($this.parents('li.pin').length) { // If on page listing multiple pins
      focusable = $this.parents('li.pin').find('.comment_form textarea').first();
      focusable.parents('.comment_form').toggle();
      focusable.parents('.masonry').masonry('reload');
      scrollTo( $this.parents('li.pin') );
    } else { // If in modal or on standalone pin#show page
      focusable = $this.parents('.pin-context').find('.comment_form textarea').first();
      if ($this.parents('.modal_overlay').length) {
        $this.parents('.modal_overlay').scrollTo( scrollToHeightFor(focusable.parents('.comments')) );      
      } else {
        scrollTo(focusable.parents('.comments'));
      }
    }
    focusable.focus();
    e.preventDefault();
    e.stopPropagation();
  });
      
  // Follow/unfollow buttons
  $(document).on('click', '.following-action', function(e) {    
    var context = $('.nav_profile').length ? ('context=' + $('.nav_profile').data('profileId')) : '';
    var url = urlPlusParamString($(this).data('url'), context);
    $.ajax({type: $(this).data('ajax-method') || 'POST', url: url});
    updateFollowingButtonsAfterClickOn(this);
    e.preventDefault();
  });
    
  // Add custom trucation
  $(document).on('click', 'a.view-more', function(e) {
    e.preventDefault();
    e.stopPropagation();
    var wrapper = $(e.target).parent();
    if (wrapper.data('original-text')) {
      if (!wrapper.data('short-text')) wrapper.data('short-text', wrapper.html());
      var longer = wrapper.data('original-text') + ' ' + '<a href="#" class="view-less">(less)</a>';
      wrapper.html(longer);
      window.kt = wrapper;
      wrapper.parents('.masonry').masonry('reload');
    }
  });
  
  $(document).on('click', 'a.view-less', function(e) {
    e.preventDefault();
    e.stopPropagation();
    var wrapper = $(e.target).parent();
    if (wrapper.data('short-text')) {
      wrapper.html( wrapper.data('short-text') );
      scrollTo(wrapper.parents('.masonry-brick'));
      wrapper.parents('.masonry').masonry('reload');
    }
  });
          
  // As a function because shared with popup.js
  handlePopupWindows();
  
  // Handle sorting on boards page
  $(document).on('click', 'a.start-sorting', function(e) {
    e.preventDefault();
    var toSort = $( $(this).data('sort') );
    var endpoint = $(this).data('endpoint');
    if (startSorting(toSort, endpoint)) {
      $(this).hide().siblings('a.stop-sorting').show();
    }
  });
  
  $(document).on('click', 'a.stop-sorting', function(e) {
    e.preventDefault();
    var toSort = $( $(this).data('sort') );
    stopSorting(toSort);
    $(this).hide().siblings('a.start-sorting').show();
  });
  
  // Pin listing pages - if pin image too small, .actions will overlay entirely. Clicking on actions but NOT on one of its buttons should open normal pin link
  $('ul.masonry').on('click', 'li.pin .actions', function(e) {
    if (e.target.className.match(/actions/)) {
      $(e.target).siblings('a.image_link').click();
    }
  });
  
  // Anchor links
  $('.internal_nav a, a.internal_nav').on('click', function(e) {
    var href = $(e.target).attr('href');
    if (href && href[0] == '#' && $(href)) {
      e.preventDefault();
      e.stopPropagation();
      scrollTo($(href), {duration: 300});
    }
  });
  
});