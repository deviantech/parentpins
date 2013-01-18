// =============================================================
// = Handles live-updating contents when creating/editing pins =
// =============================================================

var $pinForm = $('form.edit_pin');
var $outletBase = $('#pin-preview');

if ($pinForm.length) {
  var $pinImage = $outletBase.find('.pin_image');
  $pinImage.data('original-src', $pinImage.attr('src'));

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
    if ($(this).val() == 'product') {
      $pinForm.find('.field-price').removeClass('hidden').slideDown();
      $('#pin_price').trigger('change');
    } else {
      $pinForm.find('.field-price').slideUp();
      $outletBase.find('.bind-price').addClass('hidden');
    }
  });
  
  // Trigger once to initialize
  $pinForm.find('input, select').each(function() {
    if ($(this).attr('id') && $(this).attr('type') != 'hidden') updateBindingsFor(this);
  });
}

function updateBindingsFor(target) {
  var $field = $(target);
  if (($field.attr('id') || '').indexOf('pin_') == -1) {
    console.log('Attempting to update bindings for unknown field: ', target);
  }
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
  
  if (name == 'image') {
    if ($field.val() == '') {
      $('.pin_image_holder').addClass('hidden');
      $pinImage.removeClass('hidden');
      
      if ($('#pin_image_cache').val() == '') {
        $pinImage.attr('src', '/assets/fallback/pin_image/v192_default.jpg');
      } else {
        $pinImage.attr('src', $pinImage.data('original-src'));
      }      
    } else {
      $pinImage.addClass('hidden');
      if (!$('.pin_image_holder').length) {
        $pinImage.parent().append( $('<div class="pin_image_holder">New Image</div>') );
      }
      $('.pin_image_holder').removeClass('hidden');      
    }
  }
  
  var value = $field.val();
  if (!value.length) value = $field.attr('placeholder');
  return value;
}


