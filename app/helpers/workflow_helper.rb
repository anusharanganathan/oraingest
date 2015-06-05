module WorkflowHelper
  
  def application_name
    'MyORA'
  end
  
  # Renders a <span> with submission workflow status, flagged in css with either info, success, or important
  # If audience is set to :reviewer, different css labels are rendered
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
    
end
