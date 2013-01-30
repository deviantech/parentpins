module ProfileHelper

  def profile_nav_link(action)
    string = action.to_s.titleize
    
    # Make singular if needed
    string = 'Followers' if string == 'Followed By'
    string = string[0, string.length-1] if action != :following && string[-1] == 's' && @profile_counters[action].to_i == 1
    
    txt = content_tag(:span, @profile_counters[action], :class => 'counter') + ' ' + content_tag(:span, string, :class => 'label')
    url = action == :boards ? profile_boards_path(@profile) : self.send("#{action}_profile_path", @profile)
    classes = [action, current_page?(url) ? 'active' : nil].compact.join(' ')
    
    link_to(txt.html_safe, url, :class => classes)
  end
    
end
