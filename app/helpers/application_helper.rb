module ApplicationHelper
  
  def format_date(date_string)
    unless date_string.nil?
      begin
        return Time.parse(date_string).strftime("%Y-%m-%d")
      rescue ArgumentError
        # This means the date_submitted value is not a valid date.  
        return date_string
      end
    end
  end
    
end
