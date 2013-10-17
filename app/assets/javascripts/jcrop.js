// Requiring jcrop from gem. Indirection required to be sure it gets properly precompiled.
// Also includes page-specific JS.
//
//= require jquery.Jcrop.min


$(document).ready(function() {
  $('.croppable').each(function() {
    var wrapper = $(this);
    var fullImg = wrapper.find('.croppable'), 
        previewImg = wrapper.find('.crop_preview'), 
        desiredHeight = wrapper.data('height'), 
        desiredWidth = wrapper.data('width'),
        croppableName = wrapper.data('croppable');
    
    function showPreview(coords) {
    	var rx = desiredWidth / coords.w;
    	var ry = desiredHeight / coords.h;
      var actualW = fullImg[0].naturalWidth;
      var actualH = fullImg[0].naturalHeight;
    
    	previewImg.css({
    		width: Math.round(rx * actualW) + 'px',
    		height: Math.round(ry * actualH) + 'px',
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
      boxWidth: 950,
      boxHeight: 500
    };
  
    // Initialize preview to match existing thumbnail
    var initCoords = {};
    $.each('x y w h'.split(' '), function() {
      initCoords[this] = parseInt( $('#'+croppableName+'_'+this).val(), 10 );
    });
    if (initCoords.w && initCoords.h) {
      cropOpts['setSelect'] = [initCoords.x, initCoords.y, initCoords.x + initCoords.w, initCoords.y + initCoords.h];
    }

    fullImg.Jcrop(cropOpts);  
  });
});