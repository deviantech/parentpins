# Define global functions
Global.closeModal = -> 
  if $('#ajax-modal-target:visible').hasClass('update-history')
    if History.getState().data.from
      History.replaceState(null, null, History.getState().data.from);
  $('#ajax-modal-target:visible').fadeOut ->
    $(this).removeClass('update-history').empty().show();
  

Global.updateModalContents = (html) ->
  $('#ajax-modal-target:visible .modal_overlay').html(html)

# Only close overlay if click was ON overlay (or various other wrapper elements), not just bubbled up to it.
$(document).on 'click', '.modal_overlay', (e) ->
  Global.closeModal() if $(e.target).hasClass('modal_overlay') || $(e.target).hasClass('wrapper') || $(e.target).hasClass('content')

# Close if escape key pressed
$(document).on 'keyup', (e) ->
  Global.closeModal() if (e.keyCode == 27)

# Add ajax target to body
$ajax = $('#ajax-modal-target').length || $('<div id="ajax-modal-target"></div>').appendTo($('body'))

# Catch clicks on ajax links
$(document).on 'click', 'a.ajax', (e) ->
  $ajax.html('<div class="ajax-loader"><img src="/assets/ui/loader.gif" alt="Loading" class="loader_icon"/></div>').fadeIn()
  if $(this).hasClass('update-history')
    $ajax.addClass('update-history')
    History.replaceState({from: window.location + ''}, null, $(this).attr('href'));
  else
    $ajax.removeClass('update-history')
    
  url = urlPlusParamString($(this).attr('href'), 'via=ajax')
  $ajax.load(url)
  e.preventDefault()
  e.stopPropagation()

