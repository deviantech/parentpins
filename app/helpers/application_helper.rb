module ApplicationHelper

  # TODO -- this will be replaced when we wire up actual users
  def logged_in?
    false
  end
  
  def nav_link(text, target, opts = {})
    opts[:class] ||= ''
    opts[:class]  += ' marker' if current_page?(target)
    link_to(text, target, opts)
  end
  
  def body_class
    case params[:action]
    when 'recent_pins', 'articles', 'board', 'board_landing', 'category_board'
      'full_width'
    when 'about', 'login', 'signup'
      'theme_one'
    when 'modal_edit_pin', 'modal_signup_2'
      'modal'
    when 'profile_likes', 'profile_recent', 'profile_boards', 'profile_followers', 'profile_following', 'profile_recent_empty', 'profile_specific_board', 'profile_activity'
      'profile'
    else
      ''
    end
  end
  
end
