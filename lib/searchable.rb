module Searchable
  
  # TODO: eventually use sphinx or similar for indexing
  def search(query)
    if query.blank?
      self.newest_first
    else
      field_name = column_names.include?('name') ? 'name' : 'username'
      self.newest_first.where("#{field_name} LIKE ?", "%#{query}%")
    end
  end
  
end
