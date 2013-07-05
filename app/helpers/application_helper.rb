module ApplicationHelper
  
  def format_date(date_string)
    unless date_string.nil?
      Time.new(date_string).strftime("%Y-%m-%d")
    end
  end
    
end
