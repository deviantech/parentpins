module MailerHelper
  
  def url_for_comment(comment)
    case comment.commentable
    when Pin    then pin_url(comment.commentable) + "#comment_#{comment.id}"
    when Board  then profile_board_url(comment.commentable.user, comment.commentable) + "#comment_#{comment.id}"
    end
  end
  
end