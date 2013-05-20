window.previousStep = () ->
  if (window.parent && window.parent.ppImporter)
    window.parent.ppImporter.transitionToStepOne()
  else
    alert("Sorry, can't load previous step because we don't seem to have been loaded in the bookmarklet context.")


$(document).ready () ->
  
  # Toggle price fields
  $('form.import_form').on 'change', 'input[type=radio]', () ->
    field = $(this).parents('li').find('.field-price')
    if $(this).val() == 'product'
      field.removeClass('hidden')
    else
      field.addClass('hidden')
  
  