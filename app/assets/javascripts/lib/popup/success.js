$(document).ready(function(){
  handlePopupWindows();
  if ($('.success-wrapper').length) {

    // Open link in opening window, and close the popup
    if (window.opener) {
      $(document).on('click', 'a', function(e) {
        if ($(this).hasClas('js-ignore')) return true;
        e.preventDefault();
        window.opener.location = $(this).attr('href');
        window.close();
      });
    } else {
      $('a').attr('target', '_blank');
    }

    // Automatically close success window in 10 seconds
    var seconds = 0;
    var secondsToClose = 10;
    setInterval(function() {
      seconds = seconds + 1;
      var down = secondsToClose - seconds;
      $('a.close_window .countdown').html( (down < 1) ? '&nbsp;' : "("+ down +")" );
      if (down <= 0) window.close();
    }, 1000);
  }  
});