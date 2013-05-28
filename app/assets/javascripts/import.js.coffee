window.nextStep = () ->
  if (window.parent && window.parent.ppImporter)
    window.parent.ppImporter.importCompleted()
  else
    alert("Sorry, can't complete import because we don't seem to have been loaded in the bookmarklet context.")


window.previousStep = () ->
  if (window.parent && window.parent.ppImporter)
    window.parent.ppImporter.transitionToStepOne()
  else
    alert("Sorry, can't load previous step because we don't seem to have been loaded in the bookmarklet context.")


updateOtherStatus = (fields) ->
  updateStatusField fields, '.otherStatus'

updateAgeGroupStatus = (fields) ->
  updateStatusField fields, '.ageGroupStatus'

updatePinTypeStatus = (fields) ->
  updateStatusField fields, '.pinTypeStatus'
    
updateStatusField = (fields, statusSelector) ->
  li = $(fields).first().parents('li').first()
  target = li.find(statusSelector)
  anyBlank = false
    
  $(fields).each () ->
    if $(this).is(':radio')
      name = $(this).attr('name')
      value = $(this).parent().find('input:radio[name="'+name+'"]:checked').val()
      anyBlank = true if !value
    else
      if $(this).val() == ''
        console.log(this, 'is blank')
        anyBlank = true
      else
        console.log(this, 'not blank')
  
  if anyBlank
    target.removeClass('complete').addClass('pending')
  else
    target.removeClass('pending').addClass('complete')
  
  if li.find('.status_boxes .status_box').length == li.find('.status_boxes .status_box.complete').length
    li.addClass('complete')
  else
    li.removeClass('complete')
  

$(document).ready () ->
  form = $('form.import_form')  
  
  # form.on 'submit', () ->
  #   if (form.find('li.importing_pin.complete').length == 0)
  #     alert('You need to set the Type and Age Group for each Pinterest pin before we can import it into ParentPins.')
  #     return false;
  
  form.find('li.importing_pin').each () ->
    updateOtherStatus( $(this).find('.other_input') )    

  form.find('select.age_group_id').each () ->
    updateAgeGroupStatus(this)

  form.find('input.pin_type').each () ->
    updatePinTypeStatus(this)
    
  # Handle marking pin type selected, toggle price fields
  form.on 'change', 'input.pin_type', () ->
    updatePinTypeStatus(this)
    extrafield = $(this).parents('li').first().find('.field-price')
    if $(this).val() == 'product'
      extrafield.removeClass('hidden')
    else
      extrafield.addClass('hidden')
  
  # Handle marking age group selected
  form.on 'change', 'select.age_group_id', () ->
    updateAgeGroupStatus(this)

  # Handle updating on other inputs
  form.on 'change', '.other_input', () ->
    updateOtherStatus( $(this).parents('li.importing_pin').find('.other_input') )