var Global = Global || {};

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
    if ($this.text().length > length) {
      more = '<a href="#" class="view-more">(more)</a>';
      if (!$this.data('original-text')) $this.data('original-text', $this.text());
      $this.text( $this.text().substr(0, length) );
      $this.html( $this.html() + '&hellip; ' + more);
    }
  });
}

// http://railsapps.github.com/rails-javascript-include-external.html
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
  selector = selector || '.masonry'
  $(selector).masonry({
    columnWidth: 10,
    gutterWidth: 6,
    itemSelector: 'li',
    isAnimated: !Modernizr.csstransitions,
    isFitWidth: true
  }).imagesLoaded(function() {
    $(this).masonry('reload');
  });  
}

function viewAllComments(link) {
  var div = $(link).parents('.comment');
  div.hide();
  div.siblings('.comment').removeClass('hidden');
  div.parents('.masonry').masonry('reload');
}