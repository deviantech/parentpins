module ApplicationHelper

  def dummy_block(*args)
    yield
  end

  def pin_spinner(pin)
    content_tag(:div, :class => 'pin-processing', :data => {'pin-id' => pin.id}) do
      content_tag(:span) do 
        image_tag('ui/spinner.gif')
      end
    end
  end
        
  def show_pin_image(pin)
    extra = pin.image_processing? ? pin_spinner(pin) : ''
    image_tag(pin.image.url, :alt => "Image for pin from #{pin.domain}", :class => 'pin_image') + extra
  end
  
  def pin_image_preloader(pin)
    pin = @source if pin.new_record? && @source
    
    def styleFor(h, color)
      "width: 222px; height: #{h}px; background: ##{color}; color: ##{contrast_color_for(color)}"
    end  
    
    inlineBase    = "width: 222px;"
    color         = pin.image_average_color || '555555'
    scaledHeight  = pin.image? ? pin.image_v222_width : 294
            
    preload = if pin.image_processing?
      pin_spinner(pin)
    elsif pin.image? && pin.image_average_color && pin.image_v222_height && pin.image_v222_width
      
      # For images less then 222px wide, scale up
      scaledHeight = (222 / pin.image_v222_width.to_f) * pin.image_v222_height
      content_tag(:div, :class => 'img-preload-holder', :style => styleFor(scaledHeight, color)) do
        content_tag(:span, pin.domain)
      end
    end
    
    # Prefill default image placeholder sizes too
    image_tag(pin.image.v222.url, :class => 'pin_image', :alt => '', :style => styleFor(scaledHeight, color), :height => scaledHeight, :width => 222) + preload
  end

  # Choose white or black for contrasting txt.
  # Based on http://charliepark.tumblr.com/post/827693445/calculating-color-contrast-for-legible-text-in-ruby
  def contrast_color_for(hex)
    color = hex.to_s.scan(/.{2}/).sum {|c| c.to_i(16)}
    color < 382.5 ? 'FFFFFF' : '000000'
  end

  def fb_invite_url
    url = profile_boards_url(current_user)
    "https://www.facebook.com/dialog/send?app_id=#{AUTH[:facebook][:key]}&link=#{url}&redirect_uri=#{url}"
  end

  def meta_description
    if @pin && !@pin.new_record?
      "#{@pin.user.name}'s pinned #{@pin.kind} on ParentPins (#{@pin.board.category.name} | #{@pin.age_group.name})"
    elsif @board && !@board.new_record?
      "#{@board.user.name}'s ParentPins board: #{@board.name} (#{@board.category.name})"
    elsif @profile && !@profile.new_record?
      "#{@profile.name}'s curated collection of kid and parenting-related resources from around the web."
    else
      "ParentPins: kid and parenting-related resources curated from around the web by parents and educators like you."
    end
  end

  def meta_tags
    tags = []
    tags << meta_tag( 'fb:app_id',      AUTH[:facebook][:key])
    tags << meta_tag( 'og:site_name',   'ParentPins')
    tags << meta_tag( 'twitter:site',   '@ParentPins')
    
    title, desc, url, img = if @pin && !@pin.new_record?
      title = "#{@pin.user.name}'s pinned #{@pin.kind} on ParentPins (#{@pin.board.category.name} | #{@pin.age_group.name})"
      desc  = @pin.description || ''
      url   = pin_url(@pin)
      img   = absolute_url @pin.image.url
      
      tags << meta_tag( 'og:type',         @pin.kind == 'idea' ? 'website' : @pin.kind)
      tags << meta_tag( 'twitter:card',    @pin.kind == 'product' ? 'product' : 'photo')
      if @pin.kind == 'product'
        tags << meta_tag( 'product:price:amount',    @pin.price)
        tags << meta_tag( 'product:price:currency',  'USD')
        tags << meta_tag( 'twitter:data1',    @pin.price)
        tags << meta_tag( 'twitter:label1',  'Price')
        tags << meta_tag( 'twitter:data2',    @pin.domain)
        tags << meta_tag( 'twitter:label2',  'Source')
      end
      
      if @pin.user.twitter_account
        tags << meta_tag( 'twitter:creator',  "@#{@pin.user.twitter_account}")
      end
      

      
      [title, desc, url, img]
    elsif @board && !@board.new_record?
      title = "#{@board.user.name}'s ParentPins board: #{@board.name} (#{@board.category.name})"
      desc  = @board.description || ''
      url   = profile_board_url(@board.user, @board)
      img   = absolute_url @board.cover.url
      
      tags << meta_tag( 'og:type',        'website')      
      tags << meta_tag( 'twitter:card',   'gallery')
      @board.pins.with_image.limit(4).each_with_index do |pin, idx|
        tags << meta_tag( "twitter:image#{idx}:src",   absolute_url(pin.image.v222.url))
      end
      
      [title, desc, url, img]
    elsif @profile && !@profile.new_record?
      title = "#{@profile.name}'s ParentPins Profile"
      url   = profile_boards_url(@profile)
      img   = absolute_url @profile.avatar.main.url

      desc = @profile.name
      desc += @profile.teacher? ? " is a teacher with " : ' has '
      desc += "#{pluralize @profile.pins.count, 'pin', 'pins'} on #{pluralize @profile.boards.count, 'board', 'boards'}."
      desc += " Bio: #{@profile.bio}" unless @profile.bio.blank?
      
      tags << meta_tag( 'og:type',        'website')      
      tags << meta_tag( 'twitter:card',   'summary')
      
      [title, desc, url, img]
    end

    if title && url
      tags << meta_tag( 'og:title',        truncate(title, :length => 90))
      tags << meta_tag( 'og:description',  truncate(desc, :length => 295))
      tags << meta_tag( 'og:url',          url)
      tags << meta_tag( 'og:image',        img)

      tags << meta_tag( 'twitter:title',       truncate(title, :length => 65))
      tags << meta_tag( 'twitter:description', truncate(desc, :length => 195))
      tags << meta_tag( 'twitter:url',         url)
      tags << meta_tag( 'twitter:image',       img)
    end
    
    tags.join("\n").html_safe
  end
  
  def meta_tag(prop, content)
    tag(:meta, :property => prop, :content => content)
  end

  def tooltip(title, opts = {})
    opts.merge({:rel => 'tooltip', :title => title, 'data-placement' => opts.delete(:placement) || 'right'})
  end
  
  def popover(title, content, opts = {})
    opts.merge({:rel => 'popover', :title => title, :data => {:content => content, :placement => 'right'}})
  end

  def popover_for(obj, opts = {})
    title, content = case obj
    when User
      desc = pluralize(obj.boards.count, 'board', 'boards') + ' and ' + pluralize(obj.pins.count, 'pin', 'pins')
      [obj.name, desc]
    else nil
    end
        
    title ? popover(title, content, opts) : {}
  end
  
  def truncated(txt, maxlength = 20)
    opts = tooltip(txt, :placement => 'top') if txt.to_s.length > maxlength
    content_tag(:span, truncate(txt, :length => maxlength), opts || {}).html_safe
  end
  
  def display_teacher_info(user)
    return 'Not a teacher' unless user.teacher?
    base = ["<strong>#{truncated(h(user.name))} is a teacher</strong>".html_safe]

    unless user.teacher_subject.blank?
      base << "Subject: #{truncated(h(user.teacher_subject), 10)}"
    end
    
    unless user.teacher_grade.blank?
      base << "Grade: #{truncated(h(user.teacher_grade), 14)}"
    end
    
    base.join("<br>").html_safe
  end

  def thumbnails_for_board(b, n = 4)
    urls = b.thumbnail_urls(n)
    (n - urls.length).times do
      urls.push asset_path('fallback/pin_image/v55_missing.jpg')
    end
    urls
  end

  # Unfortunately since renaming e.g. boards -> board in routes.rb, we can no longer naively do "render @boards"
  def partial_for_class(m)
    case m
    when User   then 'users/user'
    when Board  then 'board/board'
    when Pin    then 'pins/pin'
    else m
    end
  end
  
  def absolute_url(url)
    return url if url =~ /\Ahttp/i
    url = [host, url].join('/').gsub(/\/{2,}/, '/')
    url = "http://#{url}" unless url =~ /\Ahttp/i
    url
  end

  def share_pin_via_fb_link(pin)
    url = "https://www.facebook.com/sharer/sharer.php?u=#{pin_url(pin)}"
    
    # NOTE: if add image, give it the js-new-window-popup class too
    link_to 'Share on FB', url, :data => {:height => 315, :width => 626}, :class => 'js-new-window-popup btn sec_action fb_button'
  end

  def share_pin_via_email_link(pin)
    opts = {
      :subject  => 'Check out this Pin',
      :body     => "#{absolute_url(url_for(pin))}\n\n#{pin.description}"
    }
    
    link_to 'Email This', "mailto:?#{opts.to_param.gsub('+', '%20')}", :class => 'btn sec_action email_button modal_only'
  end
  
  def render_paginated_result(r)
    if r.is_a?(Board)
      render :partial => 'board/board', :object => r
    elsif r.is_a?(Comment)
      render :partial => 'board/comment', :object => r
    else
      render r
    end
  end
  
  def bookmarklet_link
    link_to 'ParentPin It!', bookmarklet_link_target_js
  end  

  def pagination_link
    # No link if we're not paginating or don't have additional pages to show
    return unless @results && @results.respond_to?(:total_entries) && @results.total_entries > @results.length
    
    n = params[:page].to_i
    n = 1 if n.zero?
    n = n + 1
    next_page_link = url_for( params.merge(:page => n) )
    link_to 'Load More', next_page_link, :class => "btn action load_more_button for-ajax-pagination tertiary_action", :'data-next-page' => n
  end

  def include_javascript_for_modal(js)
    if params[:via] == 'ajax' # We're in a modal, load inline
      javascript_include_tag(js)
    else # Rendering with a normal layout, put the JS at the end of the page
      content_for(:footer_js) do
        javascript_include_tag(js)
      end
    end
  end

  def modal_class
    params[:via] == 'ajax' ? 'modal_overlay' : nil
  end
  
  # Render inline if in modal, else in footer
  def modal_footer_js(&block)
    if params[:via] == 'ajax'
      block.call
    else
      content_for :footer_js, &block
      ''
    end
  end

  def select_options(collection)
    collection.collect do |item|
      if item.is_a?(Array)
        item # Allow passing in e.g. ["No Age Group", ''] directly
      else
        item.respond_to?(:name) ? [item.name, item.id] : [item.titleize, item]
      end
    end
  end

  def avatar_link(user, version = 'v50')
    link_to image_tag(user.avatar.send(version).url, :alt => "#{user.name}'s avatar"), profile_path(user), :class => 'avatar_link'
  end

  def error_messages_for(resource)
    return '' if resource.errors.empty?
    
    content = resource.errors.full_messages.collect do |msg|
      content_tag('li', msg, :class => 'errorLineItem')
    end.join("\n")
    content_tag('ul', content.html_safe, :class => 'errors')
  end    
  
  def nav_link(text, target, opts = {})
    opts[:class] ||= ''
    opts[:class]  += ' marker' if current_page?(target) && !opts[:skip_marker]
    opts[:class]  += ' marker' if opts[:also_accept] && current_page?(opts[:also_accept])
    link_to(text, target, opts)
  end
  
  def background_class_names
    "custom"
  end
  
  

  
  def body_decorations
    str = ''
    
    klass = if @profile then 'profile'
    else
      case params[:controller]
      # full_width also available here but currently depricated due to front end UI support
      when 'pins'                 then params[:action] == 'index' ? background_class_names : ''
      when 'search', 'featured'   then background_class_names
      when 'profile'              then 'profile'
      when 'board'
        %w(index).include?(params[:action]) ? background_class_names : nil
      when 'pins'
        params[:action] == 'index' ? 'custom' : nil
      else nil
      end
    end
    
    str += %Q{ class="#{klass}"} if klass
    
    if params[:controller] == 'front' && params[:action] == 'faq'
      str += ' data-spy="scroll" data-target="#faq_nav_wrapper"'
    end
    
    str.html_safe
  end
  
end
