module UploaderHelpers
  extend ActiveSupport::Concern
  
  included do
    before_save :set_uploader_tokens

    uploaders.each do |name, klass|
      validates_integrity_of  name
      validates_processing_of name
    end
    
    # Important to have it created when viewed, because otherwise returns nil when used in an uploader's filename method
    uploaders.each do |name, klass|
      define_method "#{name}_token" do
        if self.respond_to?("#{name}_token")
          set_uploader_tokens if self["#{name}_token"].blank?
          self["#{name}_token"]
        else
          Rails.logger.info "#{self.class.name} doesn't appear to have a #{name}_token defined"
        end
      end
    end
  end


  protected

  def set_uploader_tokens(length = 16)
    self.class.uploaders.each do |name, klass|
      self["#{name}_token"] ||= SecureRandom.hex(length / 2) if self.respond_to?("#{name}_token=")
    end
  end
end