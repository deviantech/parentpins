class AdminMailer < BaseMailer
  layout 'admin_mailer'
  
  def new_feedback(fid)
    @feedback = Feedback.find(fid)
    mail(:to => 'info@parentpins.com', :subject => "[ParentPins] [#{Rails.env}] New  Feedback")
  end

  def alert_to_admin(msg, *vars)
    @msg = msg
    @vars = vars
    mail(:to => 'kali.donovan+pp@gmail.com', :subject => "[ParentPins] [#{Rails.env}] Admin Alert: #{msg.to_s[0,30]}")
  end
  
end
