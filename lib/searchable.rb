module Searchable
  
  # TODO: eventually use sphinx or similar for indexing
  def search(query)
    base_scope = self.newest_first
    unless query.blank?
      fields = case self.name
      when "Board"  then %w(name description)
      when "User"   then %w(username bio)
      when "Pin"    then %w(description)
      else []
      end
      
      str = fields.map {|f| "(#{f} LIKE :query)"}.join(' OR ')
      base_scope = base_scope.where(str, {:query => "%#{query}%"})
    end
    
    # TODO - make more efficient (sphinx? - currently returns count for each, which isn't needed) and/or eventually remove once have more pins in play.
    if self.respond_to?(:uniq_source_url)
      base_scope = base_scope.uniq_source_url
    end
      
    
    base_scope
  end

end
