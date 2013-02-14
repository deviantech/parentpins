//  History API when opening pin in modal
(function(window,undefined){

    // Prepare
    var History = window.History;
    if ( !History.enabled ) return false;

    // Bind to StateChange Event
    History.Adapter.bind(window,'statechange',function() {
        var State = History.getState();
        console.log(State.url, State.title, State.data);
    });

    // TODO: in modal.js,   History.replaceState({origURL: window.location + ''}, null, $(this).attr('href'));
    // TODO: in modal.js,  when modal closed, see if pushed state, if so un-push it.
})(window);
