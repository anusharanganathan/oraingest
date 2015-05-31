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

  def initialize(host, username='', password='')
    # Initiate the connection with the databank <host>. 
    # Optionally, also specify <username> and <password>
    if host.end_with?('/')
      host = host[0...-1]
    end
    @resource = RestClient::Resource.new(host, :user => username, :password => password)
    #@resource = RestClient::Resource.new(host, :user => username, :password => password, :ssl_version => 'TLSv1')
  end

  def getSilos()
    #  Get a list of silos in this repository
    begin
      data = @resource['/silos'].get(:accept => 'application/json')
      #data.headers
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, JSON.parse(data.body))
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
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, data.body)
  end

  def deleteSilo(silo)
    begin
      data = @resource["/#{silo}/admin"].delete
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, data.body)
  end

  def getDatasets(silo)
    # Get a list of datasets within the <silo>
    # Only the first 100...
    begin
      data = @resource["/#{silo}"].get(:accept => 'application/json')
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, JSON.parse(data.body))
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
    rescue => e
      return (nil, e.response.code, e.response.headers, e.response.description)
    end
    return (data.body, data.code, data.headers, data.description)
  end

  def getDataset(silo, dataset)
    # Get a list of datasets within the <silo>
    # Only the first 100...
    begin
      data = @resource["/#{silo}/datasets/#{dataset}"].get(:accept => 'application/json')
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, JSON.parse(data.body))
  end

  def deleteDataset(silo, dataset)
    begin
      data = @resource["/#{silo}/datasets/#{dataset}"].delete
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, data.body)
  end

  def uploadFile(silo, dataset, filepath, filename=nil)
    if filename.nil?
      filename = File.basename filepath
    end
    files = {:file => File.new(path, 'rb'), :filename => filename}
    begin
      data = @resource["/#{silo}/datasets/#{dataset}"].post(files, :accept => 'application/json')
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, data.body)
  end

  def getFile(silo, dataset, filename)
    begin
      data = @resource["/#{silo}/datasets/#{dataset}/#{filename}"].get
    rescue => e
      return create_response(e.response, nil)
    end
    return create_response(data, data.body)
  end

  private

  def create_response(response, results)   
    return { 'code' => response.code, 'description' => response.description, 'results' => results)
  end

  def responseGood(code)
    return 200 <= code <= 299
  end
#silo="general"
#host="10.0.0.110", user="orauser", password="G6eNK2MxWe6x"
