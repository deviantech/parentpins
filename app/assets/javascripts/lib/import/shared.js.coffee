window.multiDragOpts = {
    revertDuration: 0,
    cursorAt: null,
    helper: (e) ->
      item = $(e.currentTarget)
      if item.hasClass('ui-selected') || item.parent().children('.ui-selected').length == 0
        # Build the actual helper
        item.addClass('ui-selected')
        helper = $('<div class="multi-drag-helper"/>')
        wrapper = $('<div class="multi-drag-helper-inner-wrapper"/>')
        
        origElements = item.parent().children('.ui-selected')
        clones = origElements.clone().removeClass('ui-selected')      
        helper.data('origElements', origElements).append( wrapper.append(clones) )
        total = origElements.length
      
        if total > 1
          counter = $("<div class='multi-drag-helper-counter'>#{origElements.length}</div>")
          helper.prepend(counter)
      
        helper.find('li').each (idx, clone) ->
          offset = total - idx
          $(clone).css({top: offset * 2, left: offset * 5, position: 'absolute', zIndex: idx})
        return helper
      
      else
        # Return default helper -- start function will kill the drag
        item.clone().removeAttr("id")
    start: (e, ui) ->
      item = $(e.currentTarget)
    
      # If already selected, and ctrl-click, just unselect
      if item.hasClass('ui-selected') && (e.metaKey || e.altKey || e.ctrlKey)
        setTimeout (() -> item.removeClass('ui-selected')), 10
        return false

      # If we're already part of a selection, or if nothing is selected and we were just clicked on, allow dragging    
      if item.hasClass('ui-selected') || item.parent().children('.ui-selected').length == 0
        item.addClass('ui-selected')
        item.parent().children('.ui-selected').css('opacity', 0.5)
        $('body').css('cursor', 'move')
        
      # Other things are selected, we're not, and we were clicked on == skip dragging, allow selectable to do it's thing
      else
        return false
    stop: (e, ui) ->
      $(this).css('opacity', 1.0)
      $('body').css('cursor', 'auto')
  }
  
$(document).ready () ->
  form = $('#import_form')
  $('.import_progress a.previous').on 'click', (e) ->
    e.preventDefault()
    console.log 'clicked', form
    form.data('go-back', true)
    form.attr('action', $(this).attr('href'))
    form.submit()
  