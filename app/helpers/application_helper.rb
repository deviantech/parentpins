module ApplicationHelper
  
  def nav_link(text, target, opts = {})
    opts[:class] ||= ''
    opts[:class]  += ' marker' if current_page?(target)
    link_to(text, target, opts)
  end
  
  def body_class
    if params[:action] == 'recent_pins'
      'full_width'
    else
      ''
    end
  end
  
end
