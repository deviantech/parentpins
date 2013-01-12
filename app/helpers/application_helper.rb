module ApplicationHelper

  def modal_class
    params[:via_ajax] ? 'pinly_overlay' : nil
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
    when 'profiles' then 'profile'
    when 'pins', 'boards'
      params[:action] == 'index' ? 'full_width' : nil
    else nil
    end
  end
  
end
