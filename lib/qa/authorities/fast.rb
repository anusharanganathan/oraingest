require 'uri'

module Qa::Authorities
  class Fast < WebServiceBase

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize
    end

    def search(q, sub_authority=nil)
      if ! (sub_authority.nil?  || Fast.sub_authorities.include?(sub_authority))
        @raw_response = nil
        @response = nil
        return
      end

      q = URI.unescape(q)
      q = URI.escape(q)
      numRows = 20
      queryRetrun = "suggestall,idroot,auth,type,tag,raw,breaker,indicator"
      authority_fragment = Fast.sub_authority_table[sub_authority]
      query_url =  "http://fast.oclc.org/searchfast/fastsuggest?query=#{q}&queryIndex=#{authority_fragment}&queryReturn=#{queryRetrun}&numRows=#{numRows}&suggest=autoSubject"
      @raw_response = get_json(query_url)
      @response = parse_authority_response(@raw_response)
    end

    def self.sub_authority_table
      @sub_authority_table ||=
        begin
          {
            'all' => "suggestall",
            'personalName' => "suggest00",
            'corporateName' => "suggest10",
            'event' => "suggest11",
            'uniformTitle' => "suggest30",
            'topical' => "suggest50",
            'geographicName' => "suggest51",
            'form' => "suggest55",
          }
        end
    end


    def self.authority_valid?(authority)
      self.sub_authorities.include?(authority)
    end

    def self.sub_authorities
      @sub_authorities ||= sub_authority_table.keys
    end

    def parse_authority_response(raw_response)
      ans = []
      raw_response['response']['docs'].each do |doc|
        ans.push(fast_response_to_qa(doc))
      end
      ans
      #raw_responses.select {|response| response[0] == "atom:entry"}.map do |response|
      #  loc_response_to_qa(response_to_struct(response))
      #end
    end

    # Converts most of the atom data into an OpenStruct object.
    #
    # Note that this is a pretty naive conversion.  There should probably just
    # be a class that properly translates and stores the various pieces of
    # data, especially if this logic could be useful in other auth lookups.
    def response_to_struct(response)
      result = response.each_with_object({}) do |result_parts, result|
        next unless result_parts[0]
        key = result_parts[0].sub('atom:', '').sub('dcterms:', '')
        info = result_parts[1]
        val = result_parts[2]

        case key
          when 'title', 'id', 'name', 'updated', 'created'
            result[key] = val
          when 'link'
            result["links"] ||= []
            result["links"] << [info["type"], info["href"]]
        end
      end

      OpenStruct.new(result)
    end

    # Conversion from Fast hash to QA hash
    def fast_response_to_qa(data)
      resp = {
        "id" => data['idroot'].sub(/fst/,'') || data['auth'],
        "label" => data['auth'],
        "auth" => data['auth']
      }
      if data['type'] == "alt"
        resp["label"] = data['suggestall'][0]
      end
      resp
    end

    def find_record_in_response(raw_response, id)
      raw_response.each do |single_response|
        next if single_response[0] != "atom:entry"
        single_response.each do |result_part|
          if (result_part[0] == 'atom:title' ||
              result_part[0] == 'atom:id') && id == result_part[2]
            return single_response
          end
        end
      end
      return nil
    end

    def full_record(id, sub_authority)
      search(id, sub_authority)
      full_record = find_record_in_response(@raw_response, id)

      if full_record.nil?
        # record not found
        return {}
      end

      parsed_result = {}
      full_record.each do |section|
        if section.class == Array
          label = section[0].split(':').last.to_s
          case label
          when 'title', 'id', 'updated', 'created'
            parsed_result[label] = section[2]
          when 'link'
            if section[1]['type'] != nil
              parsed_result[label + "||#{section[1]['type']}"] = section[1]["href"]
            else
              parsed_result[label] = section[1]["href"]
            end
          when 'author'
            author_list = []
            #FIXME: Find example with two authors to better understand this data.
            author_list << section[2][2]
            parsed_result[label] = author_list
          end
        end
      end
      parsed_result
    end

  end
end
