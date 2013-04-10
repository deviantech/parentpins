class UserMailer < BaseMailer
  layout 'base_mailer'
  
  def unlock_instructions(uid)
    @user = User.find(uid)
    mail(:to => @user.email, :subject => "[ParentPins] Unlock Instructions")
  end
  
  def confirmation_instructions(uid)
    @user = User.find(uid)
    mail(:to => @user.email, :subject => "[ParentPins] Account Confirmation")
  end
  
  def password_reset(uid)
    @user = User.find(uid)
    mail(:to => @user.email, :subject => "[ParentPins] Reset Password")
  end
  
  def featured_notice(uid)
    @user = User.find(uid)
    mail(:to => @user.email, :subject => "[ParentPins] You've been selected as a Featured Pinner!")
  end
  
end
