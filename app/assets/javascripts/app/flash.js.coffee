Global.addFlashMsg = (msg, name) ->
  name ||= 'notice'
  box = $('#flash').removeClass('hidden')
  content = """
    <div class="alert alert-#{name}">
      <a class="close" data-dismiss="alert">&#215;</a>
      #{msg}
    </div>
  """  
  $(content).hide().appendTo(box).slideDown()
  Global.closeModal()

Global.setFlashMsg = (msg, name) -> 
  $('.flashmsg .close').each ->
    unless $(this).parent().hasClass('.alert-bookmarklet')
      $(this).click()
  Global.addFlashMsg(msg, name)

# Close bookmarklet flash message specially
closeBookmarkletFlash = ->
  $.post("/mark/got_bookmarklet")

$('.flashmsg.alert-bookmarklet').on 'click', '[data-dismiss="alert"]', closeBookmarkletFlash

# When last flash msg closed, hide the #flash div (margin/padding messes up page layout otherwise)
$(document).ready ->
  $('#flash').on 'close', ->
    if $('#flash .flashmsg').length == 1
      hideFlash = -> $('#flash').addClass('hidden')
      setTimeout hideFlash, 100
