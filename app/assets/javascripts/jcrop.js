// Requiring jcrop from gem. Indirection required to be sure it gets properly precompiled.
// Also includes page-specific JS.
//
//= require jquery.Jcrop.min


$(document).ready(function() {
  $('.croppable_container').each(function() {
    var wrapper = $(this);
    
    var fullImg = wrapper.find('.jcrop_full_image'), 
        previewImg = wrapper.find('.crop_preview'), 
        previewWrap = wrapper.find('.crop_preview_wrapper'),
        desiredHeight = wrapper.data('height'), 
        desiredWidth = wrapper.data('width'),
        croppableName = wrapper.data('croppable'),
        boxHeight = wrapper.data('boxheight'), 
        boxWidth = wrapper.data('boxwidth');
        
    var actualHeight = fullImg.naturalHeight(),
        actualWidth  = fullImg.naturalWidth();
    

    previewWrap.css({height: desiredHeight+'px', width: desiredWidth+'px'});
    
    function showPreview(coords) {
    	var rx = desiredWidth / coords.w;
    	var ry = desiredHeight / coords.h;
    
    	previewImg.css({
    		width: Math.round(rx * actualWidth) + 'px',
    		height: Math.round(ry * actualHeight) + 'px',
    		marginLeft: '-' + Math.round(rx * coords.x) + 'px',
    		marginTop: '-' + Math.round(ry * coords.y) + 'px'
    	});
      
      $('#'+croppableName+'_x').val(coords.x);
      $('#'+croppableName+'_y').val(coords.y);
      $('#'+croppableName+'_w').val(coords.w);
      $('#'+croppableName+'_h').val(coords.h);  
    }

    var cropOpts = {
      onChange: showPreview,
    	onSelect: showPreview,
    	aspectRatio: desiredWidth / desiredHeight,
      boxWidth: boxWidth,
      boxHeight: boxHeight
    };
  
    // Initialize preview to match existing thumbnail
    var initCoords = {};
    $.each('x y w h'.split(' '), function() {
      initCoords[this] = parseInt( $('#'+croppableName+'_'+this).val(), 10 );
    });
    if (initCoords.w == actualWidth && initCoords.h == actualHeight) {
      showPreview(initCoords);
    } else {
      cropOpts['setSelect'] = [initCoords.x, initCoords.y, initCoords.x + initCoords.w, initCoords.y + initCoords.h];
    }

    fullImg.Jcrop(cropOpts);  
  });
});