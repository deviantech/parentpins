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

  }  
});