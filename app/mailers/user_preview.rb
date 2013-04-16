if ALLOW_MAIL_PREVIEW

  # This class only used in development. It allows viewing mail messages in the browser. https://github.com/37signals/mail_view
  class UserPreview < MailView
  
    # Devise::Mailer
  
    def unlock_instructions
      Devise::Mailer.unlock_instructions( User.first )
    end

    def confirmation_instructions
      Devise::Mailer.confirmation_instructions( User.first )
    end

    def reset_password_instructions
      Devise::Mailer.reset_password_instructions( User.first )
    end
  
    # UserMailer
  
    def featured_notice
      UserMailer.featured_notice( User.first.try(:id) )
    end
  
  end

end