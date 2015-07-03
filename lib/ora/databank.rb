require 'rest_client'
require 'active_support/core_ext/hash/indifferent_access'

class Databank
  # Connect to a Databank implementation
  # Responses in the form: 
  #  {
  #     'code': status_code of result, 
  #     'description': reason behind status if error, 
  # 	'results' : results from request
  #  }
  # TODO:- Check imputs are valid (e.g. valid names, file exists, etc)

  def initialize(host, username='', password='', timeout=nil)
    # Initiate the connection with the databank <host>. 
    # Optionally, also specify <username> and <password>
    if host.end_with?('/')
      host = host[0...-1]
    end
    if host.start_with?("http://")
      @resource = RestClient::Resource.new(host, :user => username, :password => password, :timeout => timeout)
    elsif host.start_with?("https://")
      @resource = RestClient::Resource.new(host, :user => username, :password => password, :ssl_version => 'TLSv1', :timeout => timeout)
    end
    @host = host
  end

  def getSilos()
    #  Get a list of silos in this repository
    begin
      data = @resource['/silos'].get(:accept => 'application/json')
      #data.headers
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, JSON.parse(data.body))
  end

  def createSilo(silo, attributes={})
    # Create a silo in this repository
    # You will need admin rights to the whole *repository* for this to succeed.
    payload = {}
    payload['silo'] = silo 
    allowedAttribs = ['administrators', 'managers', 'users', 'notes', 'description', 'title']
    attributes.with_indifferent_access.each do |k,v|
      if allowedAttribs.include?(k)
        payload[k] = v
      end
    end
    begin
      data = @resource['/admin'].post(payload, {:accept => 'application/json'})
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, data.body)
  end

  def deleteSilo(silo)
    begin
      data = @resource["/#{silo}/admin"].delete
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, data.body)
  end

  def getDatasets(silo)
    # Get a list of datasets within the <silo>
    # Only the first 100...
    begin
      data = @resource["/#{silo}"].get(:accept => 'application/json')
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, JSON.parse(data.body))
  end

  def createDataset(silo, id, label=nil, embargoed="true", embargoed_until=nil)
    # Create a dataset with <id> in <silo> . 	
    # Optionally set a <label>, <emborgoed> and <embargoed until> (ISO8601)
	
    payload = {}

    # TODO: Check ID has only these characters  0-9a-zA-Z-_:
    payload['id'] = id

    unless label.nil?
      payload['title'] = label
    end	

    if !embargoed_until.nil?
      # TODO: Check date in ISO8601
      payload["embargoed_until"] = embargoed_until
      payload["embargoed"] = embargoed
    elsif !embargoed.nil?
      payload["embargoed"] = embargoed
    end

    begin
      data = @resource["#{silo}/datasets"].post(payload, {:accept => 'application/json'})
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, data.body)
  end

  def getDataset(silo, dataset)
    # Get a list of datasets within the <silo>
    # Only the first 100...
    begin
      data = @resource["/#{silo}/datasets/#{dataset}"].get(:accept => 'application/json')
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, JSON.parse(data.body))
  end

  def deleteDataset(silo, dataset)
    begin
      data = @resource["/#{silo}/datasets/#{dataset}"].delete
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, data.body)
  end

  def uploadFile(silo, dataset, filepath, filename=nil)
    if filename.nil?
      filename = File.basename filepath
    end
    files = {:file => File.new(filepath, 'rb'), :filename => filename}
    begin
      data = @resource["/#{silo}/datasets/#{dataset}"].post(files, :accept => 'application/json')
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, data.body)
  end

  def getFile(silo, dataset, filename)
    begin
      data = @resource["/#{silo}/datasets/#{dataset}/#{filename}"].get
    rescue RestClient::Exception => e
      return create_response(e.response.code, e.response.description, nil)
    #rescue => e
    #  return create_response(500, "#{e.message}\n#{e.backtrace.join("\n")}", nil)
    end
    return create_response(data.code, data.description, data.body)
  end

  def getUrl(silo, dataset=nil, filename=nil)
    url = nil
    # build the path
    if !dataset.nil? && !filename.nil?
      path = "/#{silo}/datasets/#{dataset}/#{filename}"
    elsif !dataset.nil? 
      path = "/#{silo}/datasets/#{dataset}"
    else
      path = "/#{silo}"
    end
    # Construct the url
    begin
      if @host.start_with?("http://")
        url = URI::HTTP.build({:host => @host.sub("http://", ""), :path => path}).to_s
      elsif @host.start_with?("https://")
        url = URI::HTTPS.build({:host => @host.sub("https://", ""), :path => path}).to_s
      end
    rescue URI::InvalidComponentError
      if @host.end_with?('/')
        url = "#{@host.sub(/\/$/, '')}#{path}"
      else
        url = "#{@host}#{path}"
      end
    end
    url
  end

  def responseGood(code)
    return 200 <= code && code <= 299
  end

  private

  def create_response(code, description, results)
    return {'code' => code, 'description' => description, 'results' => results}
  end

end
