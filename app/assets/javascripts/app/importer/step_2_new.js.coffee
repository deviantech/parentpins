dropOpts = {
  hoverClass: "ui-state-active",
  drop: (event, ui) ->
    helper = $(ui.helper)
    target = $(this).find('.collection')
    console.log(target.length, helper.length, if helper.data('multidrag') then helper.data('multidrag').length else 'no data')

    if helper.hasClass('pins')
      target.append( helper.data('multidrag').css({left: 0, top: 0}).removeClass('ui-selected') )
      $(ui.draggable).remove()
}

dragOpts = {
  revert: 'invalid',
  stack: '.drag_section_wrapper li.pin',
  delay: 150, # Needed to prevent accidental drag when trying to select
  revert: 0,
  start: (event, ui) ->
    item = $(event.target).css({opacity: 0.5})
  stop: (e, ui) ->
    ui.helper.data('item').css({opacity: 1.0})
  helper: (e) ->
    helper = $('<ul class="pins"/>')
    item = $(e.currentTarget)
    if !item.hasClass('ui-selected')
      item.addClass('ui-selected').siblings().removeClass('ui-selected')
    elements = item.parent().children('.ui-selected').clone()
    item.siblings('.ui-selected').remove()
    helper.data('multidrag', elements).data('item', item).append(elements)
}

window.initStep2New = () ->
  $('.drop_section_wrapper li.drop_target').droppable(dropOpts)
  $('.drag_section_wrapper ul').selectable()
  # $('.drag_section_wrapper li.pin').draggable(dragOpts)
