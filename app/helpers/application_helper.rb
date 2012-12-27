module ApplicationHelper
  
  def nav_link(text, target, opts = {})
    opts[:class] ||= ''
    opts[:class]  += ' marker' if current_page?(target)
    link_to(text, target, opts)
  end
  
  def body_class    
    from_action = case params[:action]
    when 'recent_pins', 'articles', 'board', 'board_landing', 'category_board'
      'full_width'
    when 'about'
      'theme_one'
    when 'modal_edit_pin', 'modal_signup_2'
      'modal'
    when 'profile_likes', 'profile_recent', 'profile_boards', 'profile_followers', 'profile_following', 'profile_recent_empty', 'profile_specific_board', 'profile_activity'
      'profile'
    else
      nil
    end
    
    # return from_action unless from_action.blank?
    # 
    # case request.url
    # when /users\/sign_in/, /users\/sign_up/
    #   'theme_one'
    # else
    #   ''
    # end
  end
  
end
