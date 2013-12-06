# Requiring jcrop from gem. Indirection required to be sure it gets properly precompiled.
# Also includes page-specific JS.
#
#= require jquery.Jcrop.min


$(document).ready () ->
  $('.croppable_container').each () ->
    wrapper = $(this)
    
    fullImg = wrapper.find('.jcrop_full_image')
    previewImg = wrapper.find('.crop_preview')
    previewWrap = wrapper.find('.crop_preview_wrapper')
    desiredHeight = wrapper.data('height')
    desiredWidth = wrapper.data('width')
    croppableName = wrapper.data('croppable')
    boxHeight = wrapper.data('boxheight')
    boxWidth = wrapper.data('boxwidth')
        
    actualHeight = fullImg.naturalHeight()
    actualWidth  = fullImg.naturalWidth()
    
    
    previewWrap.css({height: desiredHeight+'px', width: desiredWidth+'px'})
    
    showPreview = (coords) ->
      ratioW = coords.w / actualWidth
      ratioH = coords.h / actualHeight
      ratioX = coords.x / actualWidth
      ratioY = coords.y / actualHeight
      
      thumbW = desiredWidth / ratioW
      thumbH = desiredHeight / ratioH
      
      previewImg.css({
        width: thumbW + 'px',
        height: thumbH  + 'px'
        marginLeft: '-' + Math.round(ratioX * thumbW) + 'px',
        marginTop: '-' + Math.round(ratioY * thumbH) + 'px'
      })
      
      $('#'+croppableName+'_x').val(coords.x)
      $('#'+croppableName+'_y').val(coords.y)
      $('#'+croppableName+'_w').val(coords.w)
      $('#'+croppableName+'_h').val(coords.h)
    
    cropOpts = {
      onChange: showPreview,
      onSelect: showPreview,
      aspectRatio: desiredWidth / desiredHeight,
      boxWidth: boxWidth,
      boxHeight: boxHeight,
      trueSize: [actualWidth, actualHeight]
    }
      
    # Initialize preview to match existing thumbnail
    initCoords = {}
    $.each 'x y w h'.split(' '), () ->
      initCoords[this] = parseInt( $('#'+croppableName+'_'+this).val(), 10 )
      
    if (initCoords.w == actualWidth && initCoords.h == actualHeight)
      showPreview(initCoords)
    else
      cropOpts['setSelect'] = [initCoords.x, initCoords.y, initCoords.x + initCoords.w, initCoords.y + initCoords.h]
    
    fullImg.Jcrop(cropOpts)