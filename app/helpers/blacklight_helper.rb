module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def application_name
    "ORA"
  end

  def document_url(model, action, id="")
    actions = ['index', 'show', 'new', 'edit', 'destroy']
    models = { "Article" => 'articles', "DatasetAgreement" => "dataset_agreements", "Dataset" => "datasets" }
    path = ""
    puts "============================"
    puts actions.include?(action)
    puts models.keys.include?(model)
    puts "============================"
    if actions.include?(action) && models.keys.include?(model)
      begin
        if id
          path = url_for(:controller => models[model], :action=>action, :id => id)
        else
          path = url_for(:controller => models[model], :action=>action)
        end
      rescue ActionController::UrlGenerationError => e
        path = ""
      end
    end 
    path
  end

end
