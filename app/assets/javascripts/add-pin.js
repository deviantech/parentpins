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

  $pinForm.on('keyup', function(e) {
    updateBindingsFor(e.target);
  });

}

function updateBindingsFor(target) {
  var $field = $(target);
  var name = $field.attr('id').replace(/pin_/, '');

  var $outlet = $outletBase.find('.bind-'+name);
  $outlet.text( $field.val() );
  runPostBindingUpdated(name, $field, $outlet);
}

// Handle custom things like showing/hiding price
function runPostBindingUpdated(name, $field, $outlet) {
  if (name == 'price') {
    var value = parseInt( $field.val().replace(/[^\d,\.]/, ''), 10);
    $outlet.text( formatMoney(value) );

    if (isNaN(value) || value == 0) {
      if (!$outlet.hasClass('hidden')) $outlet.addClass('hidden');
    } else {
      $outlet.removeClass('hidden');
    }
  }
}

function formatMoney(raw) {
  // TODO -- add money formatting logic here
  return '$' + raw;
}


// TODO - price - tabbing away seems to raise errors that keyupdoesn't. diff target?

// connect other binds for live updating