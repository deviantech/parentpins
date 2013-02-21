module PinsHelper

  def pins_index_header
    return "Trending: Parenting Articles, Ideas, & Products" unless @kind || @category
    
    str = "Trending#{':' unless @category && !@kind} "
    str += "#{@kind.pluralize.titleize}" if @kind

    if @category
      str += " under #{@category.name}"
    end
    
    return str
  end
  
end
