module ImportHelper
  
  def progress_class(step, this)
    if step < this then 'pending'
    elsif step > this then 'done'
    else 'current'
    end
  end
  
  
end
