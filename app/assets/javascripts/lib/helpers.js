//= require lib/jshelpers

window.Global = window.Global || {};

// Avoid `console` errors in browsers that lack a console.
(function() {
    var method;
    var noop = function noop() {};
    var methods = [
        'assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error',
        'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log',
        'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd',
        'timeStamp', 'trace', 'warn'
    ];
    var length = methods.length;
    var console = (window.console = window.console || {});

    while (length--) {
        method = methods[length];

        // Only stub undefined methods.
        if (!console[method]) {
            console[method] = noop;
        }
    }
}());

function moneyToFloat(str) {
  return parseFloat( str.replace(/[^\d\.]/g, ''), 10);
}

// http://www.josscrowcroft.com/2011/code/format-unformat-money-currency-javascript/
// Extend the default Number object with a formatMoney() method:
// usage: someVar.formatMoney(decimalPlaces, symbol, thousandsSeparator, decimalSeparator)
// defaults: (2, "$", ",", ".")
Number.prototype.formatMoney = function(places, symbol, thousand, decimal) {
	places = !isNaN(places = Math.abs(places)) ? places : 2;
	symbol = symbol !== undefined ? symbol : "$";
	thousand = thousand || ",";
	decimal = decimal || ".";
	var number = this, 
	    negative = number < 0 ? "-" : "",
	    i = parseInt(number = Math.abs(+number || 0).toFixed(places), 10) + "",
	    j = (j = i.length) > 3 ? j % 3 : 0;
	return symbol + negative + (j ? i.substr(0, j) + thousand : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thousand) + (places ? decimal + Math.abs(number - i).toFixed(places).slice(2) : "");
};


function capitalize(word) {
  return word.substr(0,1).toUpperCase() + word.substr(1);
}

function urlPlusParamString(url, paramString) {
  // Note that this strips off any anchor tags
  var anchor = url.match(/#.*/);
  if (anchor) url = url.replace(anchor, '');

  var newURL = (url + (url.indexOf('?') == -1 ? '?' : '&') + paramString).
    replace(/&&+/, '&').
    replace(/\?\?+/, '?').
    replace(/\?&/, '?').
    replace(/[\?&]$/, '');
    
  return newURL + (anchor ? anchor[0] : '');
}

function urlPossiblyReplacingParam(url, param, value) {
  var re = new RegExp(param + '=[^&]+');
  return urlPlusParamString(url.replace(re, ''), value ? (param + '=' + value) : '');
}

function urlReplacingPathKeepingParams(newPath) {
  return urlPlusParamString(newPath, window.location.search);
}

function urlReplacingHash(url, hash) {
  return url.split('#')[0] + '#' + hash;
}

function deparam(url) {
  var params = {};
  var paramString = url.substr(url.indexOf('?') + 1);
  $.each(paramString.split('&'), function(i, param) {
    params[param.split('=')[0]] = decodeURIComponent(param.split('=')[1]);
  });
  
  return params;
}

function updateProfileCounters(data) {
  for (var key in data) {
    var target = $('.nav_profile a.'+key);
    if (target.length) {
      target.find('.counter').html(data[key]);
      var label = capitalize(key);
      if (label == 'Followed_by') label = 'Followers';
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

function applyTruncationTo(selector, length) {
  $(selector).each(function() {
    $this = $(this);
    if (!$this.data('original-text')) $this.data('original-text', $this.text());
    
    var raw = $this.data('original-text') || $this.text();
    if (raw.length > length) {  
      more = '<a href="#" class="view-more">(more)</a>';
      $this.text( raw.substr(0, length) );
      $this.html( $this.html() + '&hellip; ' + more);
    } else if ($this.data('original-text')) { // Allow resetting if applying to shorter
      $this.text( $this.data('original-text') );
    }
  });
}

// http://railsapps.github.com/rails-javascript-include-external.html -- like getScript, except checks browser's cache first
jQuery.externalScript = function(url, options) {
  // allow user to set any option except for dataType, cache, and url
  options = $.extend(options || {}, {
    dataType: "script",
    cache: true,
    url: url
  });
  // Use $.ajax() since it is more flexible than $.getScript
  // Return the jqXHR object so we can chain callbacks
  return jQuery.ajax(options);
};

function handlePopupWindows() {
  // Automatically pop up popup window links
  $(document).on('click', '.js-new-window-popup', function(e) {
    e.preventDefault();
    var link = $(this);
    if (link[0].tagName != 'A') link = link.parents('a');
    
    var newPopupWindow = window.open(link.attr('href'), 'newPopupWindow', "menubar=no,status=no,toolbar=no,location=no,width="+link.data('width')+",height="+link.data('height'));
    if (window.focus) newPopupWindow.focus();
  });
}

function startSorting(toSort, url) {
  if (!Modernizr.draganddrop) {
    alert("Sorry, it looks like the browser you're using is too old to support drag/drop reordering!");
    return false;
  }

  function showHandles() {
    if (toSort.hasClass('masonry')) {
      toSort.addClass('hadMasonry');
      toSort.masonry('destroy');
    }
    toSort.find('.handle').slideDown();
  }

  if (toSort.hasClass('js-sorting')) {
    toSort.sortable('enable');
    showHandles();
  } else {
    toSort.addClass('js-sorting');
    toSort.find('li').each(function() {
      if ($(this).find('.handle').length == 0) $('<div class="handle"><span>Drag to Reorder</span></div>').hide().prependTo( $(this) );
      showHandles();
    });
    
    toSort.sortable({
      items: 'li',
      handle: '.handle',
      forcePlaceholderSize: true
    }).bind('sortupdate', function(e, ui) {
      var ids = toSort.find('li').map(function() { return $(this).data('sort-id'); });
      $.post(url, $.param({boards: jQuery.makeArray(ids)}));
    });
  }
  
  return true;
}
function stopSorting(toSort) {
  toSort.sortable('disable');
  if (toSort.hasClass('hadMasonry')) applyMasonry(toSort);
  toSort.find('.handle').slideUp();
}

function applyMasonry(selector) {
  selector = selector || '.masonry';

  $(selector).masonry({
    itemSelector: 'li',
    isFitWidth: true
  }).imagesLoaded(function() {
    $(selector).masonry('layout');
  });  
}

function specificCommentFromURL() {
  var matches = window.location.hash.match(/#comment_(\d+)/);
  return matches && matches[1];
}

function highlightCommentFromURL() {
  var cid = specificCommentFromURL();
  if (!cid) return;
  
  var pin_comment = $('#pinly_comment .comment_'+cid);
  if (pin_comment.length) {
    $.scrollTo(pin_comment.addClass('active'));
    return;
  }
    
  var board_comment = $('.board_comments .comment_'+cid+' .comment');
  if (board_comment.length) {
    toggleBoardComments(function() {
      $.scrollTo(board_comment.addClass('active'));
    });
    return;
  }
}

function toggleBoardComments(callback) {
  var wrapper = $("#comment_form_wrapper");
  var link = $("#comment_toggle");

  if (wrapper.is(':visible')) {
    link.text( link.data('origText') || 'See All Comments');
    wrapper.slideUp("slow");
  } else {
    link.data('origText', link.text());
    link.text('Collapse Comments');
    wrapper.slideDown("slow", function() {
      wrapper.find('textarea:visible').first().focus().select();
    });
  }
  var cb = function() {
    callback && setTimeout(callback, 100);
  }
  $("#more_comments").is(':visible') ? $("#more_comments").slideUp("slow", cb) : $("#more_comments").slideDown("slow", cb);

  $('.load_more_comments_button').trigger('click');
  return false;
}
  

function viewAllComments(link) {
  var div = $(link).hasClass('load-more') ? $(link) : $(link).parents('.load-more');
  div.hide();
  div.siblings('.comment').removeClass('hidden');
  div.parents('.masonry').masonry('layout');
}


// Wrap $.scrollTo to take into account the height of the fixed header
function scrollToHeightFor(elem) {
  elem = $(elem);
  if (!elem.length) return 0;
  var elemOffset = elem.offset() ? elem.offset().top : 0;
  
  // Handle case of pin in modal, need to consider how far modal already scrolled
  var modal_top_offset = elem.parents('.modal_overlay').find('.pin-context');
  modal_top_offset = modal_top_offset.length ? modal_top_offset.first().offset().top : 0;

  return elemOffset - $('#header_wrapper').height() - 10 - modal_top_offset;
}

function scrollTo(elem, opts) {
  // Handle case of pin in modal, need to consider how far modal already scrolled
  var modal_top_offset = $(elem).parents('.modal_overlay').find('.pin-context');
  modal_top_offset = modal_top_offset.length ? modal_top_offset.first().offset().top : 0;
  var totalOffset = modal_top_offset + $('#header_wrapper').height() + 10;
  
  $.scrollTo(elem, $.extend(opts || {}, {offset: -1 * totalOffset}));
}

function updateFollowingButtonsAfterClickOn(clicked) {
  var link = $(clicked);
  var wrapper = link.parent();
  var to_show = link.hasClass('follow') ? 'unfollow' : 'follow';

  // Handle this specific set of toggles
  wrapper.find('.following-action').addClass('hidden');
  wrapper.find('.following-action.'+to_show).removeClass('hidden');

  // If for a user, also update toggles of any owned boards shown on this page
  if (wrapper.hasClass('following-action-for-profile')) {
    var uid = wrapper.data('profile-id');
    $('.following-action-for-profile-'+uid+' .following-action').addClass('hidden');
    $('.following-action-for-profile-'+uid+' .following-action.'+to_show).removeClass('hidden');
    $('.following-action-for-board-owned-by-'+uid+' .following-action').addClass('hidden');
    $('.following-action-for-board-owned-by-'+uid+' .following-action.'+to_show).removeClass('hidden');
  }
}

function matchAllFeaturedHeights() {
  var all = $('.feature .user');
  var tallest = 0;
  all.each(function() {
    if ($(this).height() > tallest) tallest = $(this).height();
  });
  all.height(tallest + 10);
}

function applyCharacterCounterTo(selector) {
  $(selector).each(function() {
    var holder = $(this);
    var target = $('#'+holder.data('target'));
    var max = holder.data('max');
    characterCounter(holder, target, max)
  });
}
function characterCounter(holder, target, max) {
  function checkCharCount() {
    var count = target.val().length;

    if (count == 0) {
      holder.hide();
    } else if (count > max) {
      holder.show().text('(reached max characters)');
      target.val( target.val().substr(0,max) );
    } else {
      holder.show().text('('+(max - count)+' characters left)');
    }
  }
  
  target.on('keyup', checkCharCount);
  checkCharCount();
}

(function($){
  $.fn.disableSelection = function() {
    this
    .attr('unselectable', 'on')
    .css({
      '-webkit-touch-callout': 'none',
      '-webkit-user-select': 'none',
      '-khtml-user-select': 'none',
      '-moz-user-select': 'none',
      '-ms-user-select': 'none',
      'user-select': 'none'
    }).on('selectstart', false);
    
    this.children().disableSelection();
    
    return this;
  };
})(jQuery);


// Images loaded in first half second should show quickly, others can fade in nicely
window.ppImageTransitionDuration = 50;
setTimeout(function() {
  window.ppImageTransitionDuration = 600;
}, 500);

function fancyPinPreloading(selector) {
  $(selector).imagesLoaded().progress(function(instance, image) {
    if (image.isLoaded) {
      $(image.img).show().parent().find('.img-preload-holder').fadeOut(ppImageTransitionDuration);
    }
  });
  
  handleProcessingPins(selector);
}

function disableForm(selector) {
  $(selector).find('input, select, textarea').attr("disabled", "disabled");
}
function enableForm(selector) {
  $(selector).find('input, select, textarea').attr("disabled", null);
}