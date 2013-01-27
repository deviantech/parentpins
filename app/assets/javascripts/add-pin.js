// =============================================================
// = Handles live-updating contents when creating/editing pins =
// =============================================================

var $pinForm = $('form.pin_form');
var $outletBase = $('#pin-preview');

if ($pinForm.length) initPinForm();
  
function initPinForm() {
  var $pinImage = $outletBase.find('.pin_image');
  $pinImage.data('original-src', $pinImage.attr('src'));

  $pinForm.on('change', function(e) {
    updateBindingsFor(e.target);
  });

  // Note that keyup doesn't have the correct originating e.target.
  $pinForm.on('keypress', function(e) {
    // The setTimeout seems to be necessary to wait until the new value is applied. 
    setTimeout(function(){
      updateBindingsFor(e.target);
    }, 5);
  });
  
  $pinForm.on('change', '#pin_kind', setPriceVisibility);
  setPriceVisibility();
  
  function setPriceVisibility() {
    if ($pinForm.find('#pin_kind').val() == 'product') {
      $pinForm.find('.field-price').removeClass('hidden').slideDown();
      $('#pin_price').trigger('change');
    } else {
      $pinForm.find('.field-price').slideUp();
      $outletBase.find('.bind-price').addClass('hidden');
    }
  }
  
  
  
  
  // Board selection shows/hides category and age group.
  var $pinBoard = $pinForm.find('#pin_board_id');
  var $boardFields = $pinForm.find('.board-fields');
  function setBoardFieldVisibility() {
    $pinBoard.val() == '' ? $boardFields.slideDown() : $boardFields.slideUp();
  }
  $pinForm.on('change', '#pin_board_id', setBoardFieldVisibility);
  
  // Board selection: initially set to first non-blank value, make user manually choose to add new board (unless user submitted form to make a new board, but was invalid)
  if ($pinBoard.data('new-board')) {
    $pinBoard.val('');
  } else if ($pinBoard.val() == '') {
    var defaultVal = $pinBoard.find('option').filter(function() {
      return $(this).val() != '';
    }).first().val();
    if (defaultVal) $pinBoard.val(defaultVal);
  }
  setBoardFieldVisibility();
  
  // Board selection: if creating new board, autofill display name from board name field, not board_id selection
  var $boardName = $pinForm.find('#pin_board_attributes_name');
  $boardName.on('keypress', function() {
    // The setTimeout seems to be necessary to wait until the new value is applied. 
    setTimeout(function(){
      updateBindingsFor($boardName, 'board_id');
    }, 5);
  });
  
  // Trigger once to initialize
  $pinForm.find('input, select').each(function() {
    if ($(this).attr('id') && $(this).attr('type') != 'hidden') updateBindingsFor(this);
  });

  // Update the display outlet with the current value of the input field
  function updateBindingsFor(field, target) {
    $field = $(field);
    if ( !$field.attr('id').match(/(pin_|board_)/) ) {
      console.log('Attempting to update bindings for unknown field: ', target);
    }
    var target = target || $field.attr('id').replace(/pin_/, '').replace(/attributes_/, '');

    var $outlet = $outletBase.find('.bind-'+target);
    $outlet.html( displayValueForField(target, $field, $outlet) );
  }

  // Handle custom things like showing/hiding price, adding link to board name, etc.
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
      if ($field[0].tagName == 'SELECT' && $field.val().length) { // Existing board
        return 'onto <a href="/profile/'+'a'+'/board/' + $field.val() + '">' + $field.find('option:selected').text() + '</a>';
      }
      // Name of a not-yet-created board
      var boardName = $boardName.val().length ? $boardName.val() : 'New Board';
      return 'onto <strong>'+boardName+'</strong>';
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

}