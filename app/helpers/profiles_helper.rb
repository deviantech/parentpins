module ProfilesHelper

  def profile_nav_link(action)
    string = action.to_s.titleize
    string = string[0, string.length-1] if string[-1] == 's' && @profile_counters[action].to_i == 1 # Make singular if needed
    txt = [@profile_counters[action], string].compact.join(' ')
    url = self.send("#{action}_profile_path", @profile)
    classes = [action, current_page?(url) ? 'active' : nil].compact.join(' ')
    
    link_to(txt, url, :class => classes)
  end
    
end
