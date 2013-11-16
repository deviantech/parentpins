class UserMailer < BaseMailer
  layout 'base_mailer'
  
  def featured_notice(uid)
    @user = User.find(uid)
    mail(:to => @user.email, :subject => "[ParentPins] You've been selected as a Featured Pinner!")
  end

  def comment_received(cid)
    @comment = Comment.find(cid)
    @user = @comment.commentable.user
    
    @what = case @comment.commentable
    when Pin then 'pin'
    when Board then %Q{board "#{@comment.commentable.name}"}
    else 'post'
    end
    
    unless @comment.user == @user # If doesn't run mail(), will automatically return a ActionMailer::Base::NullMail instance
      mail(:to => @user.email, :subject => "[ParentPins] #{@comment.user.name} commented on your #{@what}")
    end
  end
  
end
