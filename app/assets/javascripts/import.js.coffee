window.previousStep = () ->
  if (window.parent && window.parent.ppImporter)
    window.parent.ppImporter.transitionToStepOne()
  else
    alert("Sorry, can't load previous step because we don't seem to have been loaded in the bookmarklet context.")


updateAgeGroupStatus = (field) ->
  updateStatusField field, '.ageGroupStatus'

updatePinTypeStatus = (field) ->
  updateStatusField field, '.pinTypeStatus'
    
updateStatusField = (field, statusSelector) ->
  li = $(field).parents('li').first()
  target = li.find(statusSelector)
  if $(field).val() == ''
    target.removeClass('complete').addClass('pending')
  else
    target.removeClass('pending').addClass('complete')
  
  if li.find('.status_boxes .ageGroupStatus').hasClass('complete') && li.find('.status_boxes .pinTypeStatus').hasClass('complete')
    li.addClass('complete')
  else
    li.removeClass('complete')
  

$(document).ready () ->
  form = $('form.import_form')  
  
  form.find('input[type=radio]').each () ->
    updatePinTypeStatus(this)
    # TODO: fix the initial pin type setting from radio button

  form.find('select[name=age_group_id]').each () ->
    updateAgeGroupStatus(this)
    
  # Handle marking pin type selected, toggle price fields
  form.on 'change', 'input[type=radio]', () ->
    updatePinTypeStatus(this)
    extrafield = $(this).parents('li').find('.field-price')
    if $(this).val() == 'product'
      extrafield.removeClass('hidden')
    else
      extrafield.addClass('hidden')
  
  # Handle marking age group selected
  form.on 'change', 'select[name=age_group_id]', () ->
    updateAgeGroupStatus(this)
