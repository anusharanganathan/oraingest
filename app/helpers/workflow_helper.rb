module WorkflowHelper
  
  def workflow_status_indicator(document)
    html_classes = ["label"]
    case document.submission_workflow_status
    when "Approved"
      html_classes << "label-success"
    when "Draft", "Rejected"
      html_classes << "label-important"
    else
      html_classes << "label-info"
    end
    content_tag('span', document.submission_workflow_status, class: "#{html_classes.join(" ")}").html_safe
  end
  
  def format_date(date_string)
    Time.new(date_string).strftime("%Y-%m-%d")
  end
    
end
