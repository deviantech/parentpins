if ALLOW_MAIL_PREVIEW

  # This class only used in development. It allows viewing mail messages in the browser. https://github.com/37signals/mail_view
  class AdminPreview < MailView
    
    def feedback
      AdminMailer.new_feedback( Feedback.first.try(:id) )
    end
    
    def new_user
      AdminMailer.new_user( User.first.try(:id) )
    end
    
    # Add new methods here... method name doesn't matter, but be sure to return a Mail object
  
  end

end