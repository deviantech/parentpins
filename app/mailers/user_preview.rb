if ALLOW_MAIL_PREVIEW

  # This class only used in development. It allows viewing mail messages in the browser. https://github.com/37signals/mail_view
  class UserPreview < MailView
  
    def unlock_instructions
      UserMailer.unlock_instructions( User.first.try(:id) )
    end

    def confirmation_instructions
      UserMailer.confirmation_instructions( User.first.try(:id) )
    end

    def password_reset
      UserMailer.password_reset( User.first.try(:id) )
    end
  
    def featured_notice
      UserMailer.featured_notice( User.first.try(:id) )
    end
  
  end

end