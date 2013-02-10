if Rails.env.development?

  # This class only used in development. It allows viewing mail messages in the browser. https://github.com/37signals/mail_view
  class AdminPreview < MailView
    render :layout => 'admin_mailer'
    
    def feedback
      AdminMailer.new_feedback( Feedback.first.try(:id) )
    end
    
    # Add new methods here... method name doesn't matter, but be sure to return a Mail object
  
  end

end