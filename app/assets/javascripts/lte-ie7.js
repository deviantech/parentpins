/* Use this script if you need to support IE 7 and IE 6. */

window.onload = function() {
	function addIcon(el, entity) {
		var html = el.innerHTML;
		el.innerHTML = '<span style="font-family: \'pinli\'">' + entity + '</span>' + html;
	}
	var icons = {
			'icon-pushpin' : '&#xe000;',
			'icon-pinterest' : '&#xe002;',
			'icon-bubble' : '&#xe001;',
			'icon-user' : '&#xe003;',
			'icon-cog' : '&#xe004;',
			'icon-heart' : '&#xe005;',
			'icon-star' : '&#xe006;',
			'icon-checkmark' : '&#xe007;',
			'icon-close' : '&#xe008;',
			'icon-plus' : '&#xe009;',
			'icon-minus' : '&#xe00a;',
			'icon-arrow-left' : '&#xe00b;',
			'icon-arrow-right' : '&#xe00c;',
			'icon-facebook' : '&#xe00d;',
			'icon-facebook-2' : '&#xe00e;',
			'icon-file' : '&#xe00f;',
			'icon-warning' : '&#xe010;'
		},
		els = document.getElementsByTagName('*'),
		i, attr, html, c, el;
	for (i = 0; i < els.length; i += 1) {
		el = els[i];
		attr = el.getAttribute('data-icon');
		if (attr) {
			addIcon(el, attr);
		}
		c = el.className;
		c = c.match(/icon-[^\s'"]+/);
		if (c && icons[c[0]]) {
			addIcon(el, icons[c[0]]);
		}
	}
};