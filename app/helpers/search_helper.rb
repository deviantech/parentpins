module SearchHelper
  
  def search_links(kinds)
    kinds.collect {|k| search_link(k) }.join(' | ').html_safe
  end
  
  def search_link(kind)
    link_to kind.capitalize, url_for(params.merge(:kind => kind)), :class => @kind.eql?(kind) ? 'marker' : nil
  end
  
end
