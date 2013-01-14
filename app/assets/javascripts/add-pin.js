// =============================================================
// = Handles live-updating contents when creating/editing pins =
// =============================================================



// TODO -- only call on page when needed, and include in modal if going to be loaded. WHAT IF loaded in modal, then closed, then a new modal loaded? only load once.


$pinForm = $('form.edit_pin');
$outletBase = $('#pin-preview');

if ($pinForm.length) {

  $pinForm.on('change', function(e) {
    updateBindingsFor(e.target);
  });

  // Note that keyup doesn't have the correct originating e.target.
  $pinForm.on('keypress', function(e) {
    setTimeout(function(){
      // The setTimeout seems to be necessary to wait until the new value is applied. 
      updateBindingsFor(e.target);
    }, 5);
  });
  
  $pinForm.on('change', '#pin_kind', function(e) {
    if ($(this).val() == 'gift') {
      $pinForm.find('.field-price').slideDown();
      $('#pin_price').trigger('change');
    } else {
      $pinForm.find('.field-price').slideUp();
      $outletBase.find('.bind-price').addClass('hidden');
    }
  });
}

function updateBindingsFor(target) {
  var $field = $(target);
  var name = $field.attr('id').replace(/pin_/, '');

  var $outlet = $outletBase.find('.bind-'+name);
  $outlet.html( displayValueForField(name, $field, $outlet) );
}

// Handle custom things like showing/hiding price
function displayValueForField(name, $field, $outlet) {
  if (name == 'price') {
    var value = moneyToFloat($field.val());

    if (isNaN(value) || value == 0) {
      $outlet.addClass('hidden');
    } else {
      $outlet.removeClass('hidden');
    }
    return value.formatMoney();
  }
  
  if (name == 'kind') {
    return capitalize($field.val()) + ':';
  }
  
  if (name == 'board_id') {
    return 'onto <a href="/boards/' + $field.val() + '">' + $field.find('option:selected').text() + '</a>';
  }
  
  return $field.val();
}


