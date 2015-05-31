class UpdatePublishRecordJob

  @queue = :ora_publish_status

  def self.perform(data)
    data = JSON.parse(data)
    if data['model'] == 'Article'
      obj = Article.find(data['pid'])
    elsif data['model'] == 'Dataset'
      obj = Dataset.find(data['pid'])
    end
    if data['status']
      obj.update_status('Published', data['msg'])
    else
      obj.update_status('System failure', data['msg'])
    end
    obj.save!
    if data['status'] && data['model'] == 'Dataset' && obj.doi_requested?
      unless obj.doi_registered?
        Resque.enqueue(RegisterDoiJob, data['pid'])
      end
    end
  end

end
