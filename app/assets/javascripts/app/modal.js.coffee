# Define global function
Global.closeModal = -> 
  $('#ajax-modal-target:visible').fadeOut ->
    $(this).empty().show();

# Only close overlay if click was ON overlay, not just bubbled up to it
$(document).on 'click', '.pinly_overlay', (e) ->
  Global.closeModal() if $(e.target).hasClass('pinly_overlay')

# Close if escape key pressed
$(document).on 'keyup', (e) ->
  Global.closeModal() if (e.keyCode == 27)

# Add ajax target to body
$ajax = $('#ajax-modal-target').length || $('<div id="ajax-modal-target"></div>').appendTo($('body'))

# Catch clicks on ajax links
$(document).on 'click', 'a.ajax', (e) ->
  $ajax.html('<div class="ajax-loader"><img src="/assets/ui/loader.gif" alt="loading icon" class="loader_icon"/></div>').fadeIn()
  url = urlPlusParamString($(this).attr('href'), 'via=ajax')
  $ajax.load(url)
  e.preventDefault()
  e.stopPropagation()

