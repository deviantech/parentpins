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
  return (url + (url.indexOf('?') == -1 ? '?' : '&') + paramString).
    replace(/&&+/, '&').
    replace(/\?\?+/, '?').
    replace(/\?&/, '?').
    replace(/[\?&]$/, '');
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
