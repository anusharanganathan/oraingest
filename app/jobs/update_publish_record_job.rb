class UpdatePublishRecordJob

  @queue = :ora_publish_status

  def self.perform(data)
    data = JSON.parse(data)
    if data["model"] == "Article"
      obj = Article.find(data["pid"])
    elsif data["model"] == "Dataset"
      obj = Dataset.find(data["pid"])
    end
    obj.update_status('Published', data["msg"])
    obj.save!
    if data["model"] == "Dataset" && obj.doi_requested? 
      unless obj.doi_registered?
        Resque.redis.rpush('register_doi', data["pid"])
      end
    end
  end



end
