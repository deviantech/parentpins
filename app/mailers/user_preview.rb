if ALLOW_MAIL_PREVIEW

  # This class only used in development. It allows viewing mail messages in the browser. https://github.com/37signals/mail_view
  class UserPreview < MailView
  
    # Devise::Mailer

    # Confirmation is not currently required
    # def confirmation_instructions
    #   Devise::Mailer.confirmation_instructions( User.first, {} )
    # end
  
    def unlock_instructions
      Devise::Mailer.unlock_instructions( User.first, {} )
    end

    def reset_password_instructions
      Devise::Mailer.reset_password_instructions( User.first, {} )
    end
  
    # UserMailer
  
    def featured_notice
      UserMailer.featured_notice( User.first.try(:id) )
    end
    
    def comment_received_on_pin
      c = Comment.where(:commentable_type => 'Board').detect {|c| c.user_id != c.commentable.user_id}
      UserMailer.comment_received( c.id )
    end
    
    def comment_received_on_board
      c = Comment.where(:commentable_type => 'Pin').detect {|c| c.user_id != c.commentable.user_id}
      UserMailer.comment_received( c.id )
    end
  
  end

end