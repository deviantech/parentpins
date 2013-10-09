module ImportHelper
  
  def progress_class(step, this)
    if step < this then 'pending'
    elsif step > this then 'done'
    else 'current'
    end
  end
  
  # Render as a link, if it's before this step, and just the block content otherwise
  def previous_link(step, n, &block)
    if n < step
      link_to(self.send("pin_import_step_#{n}_path"), :class => 'previous', &block)
    else
      content_tag(:span, &block)
    end
  end
  
end
