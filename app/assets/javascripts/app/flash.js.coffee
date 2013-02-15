Global.addFlashMsg = (msg, name) ->
  name ||= 'notice'
  box = $('#flash').removeClass('hidden')
  content = """
    <div class="flashmsg alert alert-#{name}">
      <a class="close" data-dismiss="alert">&#215;</a>
      <div class="flash_msg">#{msg}</div>
    </div>
  """  
  $(content).hide().appendTo(box).slideDown()
  Global.closeModal()