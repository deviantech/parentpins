module PinsHelper

  def pins_index_header
    str = ''
    str = "Recently Pinned #{@kind.pluralize.titleize}" if @kind

    if @category
      str += @kind ? ': ' : 'Recent Pins Under: '
      str += @category.name
    end
    
    str = "Trending Parenting Articles, Ideas, Gifts, & More" if str.blank?
    
    return str
  end
  
end
