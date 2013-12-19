class AdminMailer < BaseMailer
  layout 'admin_mailer'
  default :to => "info@parentpins.com"
  
  def new_feedback(fid)
    @feedback = Feedback.find(fid)
    mail(:subject => "[ParentPins] [#{Rails.env}] New Feedback", :reply_to => @feedback.email)
  end

  def new_user(uid)
    @user = User.find(uid)
    mail(:subject => "[ParentPins] [#{Rails.env}] New User (#{@user.name})")
  end

  def alert_to_admin(msg, *vars)
    @msg = msg
    @vars = vars
    mail(:to => 'kali@parentpins.com', :subject => "[ParentPins] [#{Rails.env}] Admin Alert: #{msg.to_s[0,30]}")
  end
  
end
