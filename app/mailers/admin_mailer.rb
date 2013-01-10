class AdminMailer < ActionMailer::Base
  default from: "info@parentpins.com"
  
  def new_feedback(fid)
    @feedback = Feedback.find(fid)
    mail(:to => 'info@parentpins.com', :subject => 'New  Feedback')
  end
end
