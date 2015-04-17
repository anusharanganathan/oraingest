module Sufia
  module Noid

    def Noid.doize(identifier)
      if identifier.start_with?(Noid.shoulder)
        identifier
      else
        "#{Noid.shoulder}:#{identifier}"
      end
    end

    protected
    def Noid.shoulder
      Sufia.config.doi_credentials[:shoulder]
    end
  end

  module IdService

    def self.mint_doi
      @semaphore.synchronize do
        while true
          pid = self.next_id
          return pid unless self.find_id(pid)
        end
      end
    end

    protected

    def self.find_id(doi)      
      solr_opts = {:q => "desc_metadata__doi_ssim:\"#{doi}\"", :fl=>"id", :rows=>1}
      response = ActiveFedora::SolrService.instance.conn.get('select', :params=> solr_opts)
      solr_response = Blacklight::SolrResponse.new(response, solr_opts)
      return solr_response.total > 0    
    end

  end

end
