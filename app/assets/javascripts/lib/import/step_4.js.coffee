sendMessage = (msg, explanation) ->
  if (!window.opener)
    console.log("Sorry, browser doesn't appear to support connecting to the parent window.")
  else if (!window.opener.postMessage)
    console.log("Sorry, your browser appears too old to support modern web standards.")
  else
    window.opener.postMessage(msg, '*')

window.importedPins = (pins_as_string) ->
  sendMessage("step4:imported:#{pins_as_string}")

window.importCompleted = () ->
  sendMessage("step4:done")

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
    li.find('.open_close_controls a').text('Remove pin from import')
  else
    li.addClass('skip-this-pin')
    
    # Hide various UI components
    li.find('.pin_info').hide()
    li.find('.pin_errors').hide()
    li.find('.status_boxes').hide()
    li.find('.open_close_controls a').text('Import this pin')

    # Now actually move .pin_info outside the form, so it doesn't submit
    li.find('.pin_info').insertAfter( li.parents('form') )

updatePinSelectionFromBoardCheckbox = (checkbox) ->
  $(checkbox).parents('li.importing_board').find('input[name=mass-select]').each (idx, pinbox) ->
    $(pinbox).prop('checked', $(checkbox).is(':checked'))
    updatePinSelectionFromCheckbox(pinbox)

updatePinSelectionFromCheckbox = (checkbox) ->
  checkbox = $(checkbox)
  pin = checkbox.parents('li.importing_pin')
  if checkbox.is(':checked') then pin.addClass('mass-selected') else pin.removeClass('mass-selected')
  updateMassEditingControlsVisibility()

updateMassEditingControlsVisibility = () ->
  mass = $('#mass-edit-controls')
  if count = $('input[name=mass-select]:checked').length
    mass.find('.count .number').text(count)
    unless mass.is(':visible')
      mass.find('select').val('')
      mass.find('input:checked').prop('checked', null)
      mass.fadeIn()
  else
    mass.fadeOut()

handleHideShowPriceField = (input) ->
  input = $(input)
  extrafield = input.parents('li').first().find('.field-price')
  if input.val() == 'product'
    extrafield.slideDown()
  else
    if input.data('animate') then extrafield.slideUp() else extrafield.hide()
  input.data('animate', true)
  

$(document).ready () ->
  return unless $('.context.step_4').length
  
  # For wide monitors, allow viewing side by side without weird float clearing for long images
  applyMasonry('ul.importing_pins')
  
  form = $('#import_form')
    
  form.on 'submit', () ->
    if form.find('li.importing_pin.complete').length == 0 && !form.data('go-back')
      alert('You need to fill in all required fields for each pin before we can complete the import.')
      return false;
  
  form.find('li.importing_pin').each () ->
    updateOtherStatus( $(this).find('.other_input') )
    
    inputToTest = if $(this).find('input.pin_type:checked').length
      $(this).find('input.pin_type:checked')
    else
      $(this).find('input.pin_type').first()
    updatePinTypeStatus( inputToTest )
    handleHideShowPriceField(inputToTest)

  form.find('select.age_group_id').each () ->
    updateAgeGroupStatus(this)
    
  # Handle marking pin type selected, toggle price fields
  form.on 'change', 'input.pin_type', () ->
    handleHideShowPriceField(this)
    updatePinTypeStatus(this)
      
  # Handle marking age group selected
  form.on 'change', 'select.age_group_id', () ->
    updateAgeGroupStatus(this)

  # Handle updating on other inputs
  form.on 'change keyup keypress', '.other_input', () ->
    updateOtherStatus( $(this).parents('li.importing_pin').find('.other_input') )

  # Set up pin/board selection checkboxes (initial + when changed)
  
  form.find('input[name=mass-select]').each () ->
    updatePinSelectionFromCheckbox(this)
    
  form.on 'change', 'input[name=mass-select]', () ->
    updatePinSelectionFromCheckbox(this)

  form.find('input[name=mass-select-board]').each () ->
    updatePinSelectionFromBoardCheckbox(this)
    
  form.on 'change', 'input[name=mass-select-board]', () ->
    updatePinSelectionFromBoardCheckbox(this)

  mass = $('#mass-edit-controls')
  mass.on 'change', 'select[name=age_group_id]', () ->
    newVal = $(this).val()
    form.find('.mass-selected select.age_group_id').val( newVal ).each () ->
      updateAgeGroupStatus(this)
  
  mass.on 'change', 'input', () ->
    if $(this).is(':checked')
      form.find(".mass-selected input.pin_type[value='#{$(this).val()}']").prop('checked', 'checked').each () ->
        updatePinTypeStatus(this)