window.importCompleted = () ->
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
        anyBlank = true
  
  if anyBlank
    target.removeClass('complete').addClass('pending')
  else
    target.removeClass('pending').addClass('complete')
  
  if li.find('.status_boxes .status_box').length == li.find('.status_boxes .status_box.complete').length
    li.addClass('complete')
  else
    li.removeClass('complete')
  

window.toggleImportingThisPin = (link) ->
  li = $(link).parents('li.importing_pin')
  
  if (li.hasClass('skip-this-pin'))
    li.removeClass('skip-this-pin')

    $('#'+li.attr('id')+'_pin_info').insertAfter( li.find('.pin_photo') ).show()
    li.find('.pin_errors').show()
    li.find('.status_boxes').show()
    li.find('.open_close_controls a').text('Skip this Pin')
  else
    li.addClass('skip-this-pin')
    
    # Hide various UI components
    li.find('.pin_info').hide()
    li.find('.pin_errors').hide()
    li.find('.status_boxes').hide()
    li.find('.open_close_controls a').text('Import this Pin')

    # Now actually move .pin_info outside the form, so it doesn't submit
    li.find('.pin_info').insertAfter( li.parents('form') )
  

$(document).ready () ->
  form = $('form.import_form')  
  
  form.on 'submit', () ->
    if (form.find('li.importing_pin.complete').length == 0)
      alert('You need to set the Type and Age Group for each Pinterest pin before we can import it into ParentPins.')
      return false;
  
  form.find('li.importing_pin').each () ->
    updateOtherStatus( $(this).find('.other_input') )
    
    inputToTest = if $(this).find('input.pin_type:checked').length
      $(this).find('input.pin_type:checked')
    else
      $(this).find('input.pin_type').first()
    updatePinTypeStatus( inputToTest )

  form.find('select.age_group_id').each () ->
    updateAgeGroupStatus(this)
    
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
  form.on 'change keyup keypress', '.other_input', () ->
    updateOtherStatus( $(this).parents('li.importing_pin').find('.other_input') )