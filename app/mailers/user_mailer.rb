class UserMailer < BaseMailer
  layout 'base_mailer'
  
  def featured_notice(uid)
    @user = User.find(uid)
    mail(:to => @user.email, :subject => "[ParentPins] You've been selected as a Featured Pinner!")
  end
  
end
