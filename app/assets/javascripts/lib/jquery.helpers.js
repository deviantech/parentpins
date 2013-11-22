jQuery.fn.redraw = function() {
  return this.hide(0, function() {
    $(this).show();
  });
};