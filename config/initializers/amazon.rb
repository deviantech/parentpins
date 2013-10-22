ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => AMAZON[:key],
  :secret_access_key => AMAZON[:secret]
