module Searchable
  
  # TODO: eventually use sphinx or similar for indexing
  def search(query)
    base_scope = self.newest_first
    unless query.blank?
      field_name = if column_names.include?('name') then 'name'
      elsif column_names.include?('username')       then 'username'
      else 'description'
      end
      base_scope = base_scope.where("#{field_name} LIKE ?", "%#{query}%")
    end
    
    # TODO - make more efficient (sphinx? - currently returns count for each, which isn't needed) and/or eventually remove once have more pins in play.
    if self.respond_to?(:uniq_source_url)
      base_scope = base_scope.uniq_source_url
    end
      
    
    base_scope
  end
  
end
