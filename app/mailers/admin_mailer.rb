class AdminMailer < BaseMailer
  layout 'base_mailer'
  
  def new_feedback(fid)
    @feedback = Feedback.find(fid)
    mail(:to => 'info@parentpins.com', :subject => "[ParentPins] [#{Rails.env}] New  Feedback")
  end
  
end
