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
    
    # If doesn't run mail(), will automatically return a ActionMailer::Base::NullMail instance
    if @user.email_on_comment_received? && @user != @comment.user
      mail(:to => @user.email, :subject => "[ParentPins] #{@comment.user.name} commented on your #{@what}")
    end
  end

  def followed(uid, follower_id, board_id = nil)
    @user = User.find(uid)
    @follower = User.find(follower_id)
    @board = board_id ? @user.boards.find(board_id) : nil

    if @user.email_on_new_follower? && @user != @follower
      mail(:to => @user.email, :subject => "[ParentPins] You have a new follower")
    end
  end
  
end
