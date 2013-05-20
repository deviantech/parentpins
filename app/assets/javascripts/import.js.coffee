$(document).ready () ->
  
  # Toggle price fields
  $('form.import_form').on 'change', 'input[type=radio]', () ->
    field = $(this).parents('li').find('.field-price')
    if $(this).val() == 'product'
      field.removeClass('hidden')
    else
      field.addClass('hidden')