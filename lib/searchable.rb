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
    
    # TODO - replace with a unique requirement on a digest form source image identifier?
    if self.is_a?(Pin)
      base_scope = base_scope.not_repinned
    end
      
    
    base_scope
  end
  
end
