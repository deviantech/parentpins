module Searchable
  
  # TODO: eventually use sphinx or similar for indexing
  def search(query)
    if query.blank?
      self.newest_first
    else
      field_name = if column_names.include?('name') then 'name'
      elsif column_names.include?('username')       then 'username'
      else 'description'
      end
      self.newest_first.where("#{field_name} LIKE ?", "%#{query}%")
    end
  end
  
end
