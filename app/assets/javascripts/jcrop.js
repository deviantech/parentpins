// Requiring jcrop from gem. Indirection required to be sure it gets properly precompiled.
// Also includes page-specific JS.
//
//= require jquery.Jcrop.min


$(document).ready(function() {
  $('.croppable').each(function() {
    var wrapper = $(this);
    var fullImg = wrapper.find('.croppable'), 
        previewImg = wrapper.find('.crop_preview'), 
        previewWrap = wrapper.find('.crop_preview_wrapper'),
        desiredHeight = wrapper.data('height'), 
        desiredWidth = wrapper.data('width'),
        croppableName = wrapper.data('croppable'),
        boxHeight = wrapper.data('boxheight'), 
        boxWidth = wrapper.data('boxwidth');
    
    // TODO: if viewed in a narrow viewport, this makes the preview clean up (it fitx, and box is resized by correct ratio), BUT
    // it shows incorrect information (doesn't scale the interior image, just the viewport size, so it reports a different thumbnail than reality)
    function fixThumbSize() {
      previewWrap.css({width: 'auto', height: 'auto', maxHeight: desiredHeight+'px', maxWidth: desiredWidth+'px'});
      
      // If window too narrow to fit full image, set width specifically so height will be updated by proper ratio
      if (previewWrap.width() < desiredWidth) {
        var newHeight = Math.round(previewWrap.width() / desiredWidth * desiredHeight);
        console.log(previewWrap.width(), desiredWidth, newHeight);
        previewWrap.css({width: desiredWidth+'px', height: newHeight+'px'});
      }
    }
    
    fixThumbSize();    
    $(window).on('resize', fixThumbSize);
    
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
      boxWidth: boxWidth,
      boxHeight: boxHeight
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