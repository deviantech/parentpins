module ApplicationHelper

  def pin_pagination_link
    n = params[:page].to_i
    n = 1 if n.zero?
    n = n + 1
    next_page_link = url_for( params.merge(:page => n) )
    link_to 'Load More', next_page_link, :class => "btn action load_more_button tertiary_action", :'data-next-page' => n
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
    params[:via] == 'ajax' ? 'pinly_overlay' : nil
  end

  def select_options(collection)
    collection.collect do |item|
      item.respond_to?(:name) ? [item.name, item.id] : [item.titleize, item]
    end
  end

  def avatar_link(user)
    link_to image_tag(user.avatar.v50.url, :alt => "#{user.name}'s avatar"), profile_path(user), :class => 'avatar_link'
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
    opts[:class]  += ' marker' if current_page?(target)
    opts[:class]  += ' marker' if opts[:also_accept] && current_page?(opts[:also_accept])
    link_to(text, target, opts)
  end
  
  def body_class
    case params[:controller]
    when 'search'   then 'full_width'
    when 'profiles' then 'profile'
    when 'boards'
      %w(show index).include?(params[:action]) ? 'full_width' : nil
    when 'pins'
      params[:action] == 'index' ? 'full_width' : nil
    else nil
    end
  end
  
end
