module ApplicationHelper

  def fb_invite_url
    url = profile_boards_url(current_user)
    "https://www.facebook.com/dialog/send?app_id=#{AUTH[:facebook][:key]}&link=#{url}&redirect_uri=#{url}"
  end

  def meta_description
    if @pin         then "#{@pin.user.name}'s pinned #{@pin.kind} on ParentPins (#{@pin.board.category.name} | #{@pin.age_group.name})"
    elsif @board    then "#{@board.user.name}'s ParentPins board: #{@board.name} (#{@board.category.name})"
    elsif @profile  then "#{@profile.name}'s curated collection of kid and parenting-related resources from around the web."
    else                 "ParentPins: kid and parenting-related resources curated from around the web by parents and educators like you."
    end
  end

  def meta_tags
    tags = []
    tags << meta_tag( 'fb:app_id',      AUTH[:facebook][:key])
    tags << meta_tag( 'og:site_name',   'ParentPins')
    tags << meta_tag( 'twitter:site',   '@ParentPins')
    
    title, desc, url, img = if @pin
      title = "#{@pin.user.name}'s pinned #{@pin.kind} on ParentPins (#{@pin.board.category.name} | #{@pin.age_group.name})"
      desc  = @pin.description || ''
      url   = pin_url(@pin)
      img   = absolute_url @pin.image.v222.url
      
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
    elsif @board
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
    elsif @profile
      title = "#{@profile.name}'s ParentPins Profile"
      url   = profile_boards_url(@profile)
      img   = absolute_url @profile.avatar.url

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

  def display_teacher_info(user)
    return 'Not a teacher' unless user.teacher?
    base = [content_tag(:strong, "#{h user.name} is a teacher")]

    unless user.teacher_subject.blank?
      base << "Subject: #{h user.teacher_subject}"
    end
    
    unless user.teacher_grade.blank?
      base << "Grade: #{h user.teacher_grade}"
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
    return url if url.starts_with?(/http/i)
    url = [host, url].join('/').gsub(/\/{2,}/, '/')
    url = "http://#{url}" unless url.starts_with?(/http/i)
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
  
  
  
  def extra_body_tags
    return unless params[:controller] == 'front' && params[:action] = 'faq'
    " data-spy=scroll data-target=.spy_navbar"
  end
  
  def body_class
    return 'profile' if @profile
    
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
  
end
