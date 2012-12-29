module ApplicationHelper

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
    link_to(text, target, opts)
  end
  
  def body_class
    case params[:controller]
    when 'profiles' then 'profile'
    when 'pins' then 'full_width'
    else
      case params[:action]
      when 'recent_pins', 'articles', 'board', 'board_landing', 'category_board'
        'full_width'
      when 'about'
        'theme_one'
      when 'modal_edit_pin', 'modal_signup_2'
        'modal'
      when 'profile_likes', 'profile_recent', 'profile_followers', 'profile_following', 'profile_recent_empty', 'profile_specific_board', 'profile_activity'
        'profile'
      else
        nil
      end
    end
  end
  
end
