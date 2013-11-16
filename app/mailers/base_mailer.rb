class BaseMailer < ActionMailer::Base
  default :from => "info@parentpins.com"
  helper :mailer
end