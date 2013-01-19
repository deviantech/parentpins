module Searchable
  
  def recent
    order('id DESC')
  end
  
  # TODO: eventually use sphinx or similar for indexing
  def search(query)
    if query.blank?
      self.recent
    else
      field_name = column_names.include?('name') ? 'name' : 'username'
      self.where("#{field_name} LIKE ?", "%#{query}%")
    end
  end
  
end
