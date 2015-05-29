require 'uri'

module Qa::Authorities
  class Cud < WebServiceBase

    # Initialze the Loc class with a query and get the http response from LOC's server.
    # This is set to a JSON object
    def initialize
    end

    def search(q, sub_authority=nil)
      if ! (sub_authority.nil?  || Cud.sub_authorities.include?(sub_authority))
        @raw_response = nil
        @response = nil
        return
      end

      # Build the query term
      # AND on each word in search term
      # Only get current people from CUD (with oxford email address)
      q = URI.unescape(q)
      if q.split('').last != '*'
        q = q + '*'
      end
      query = []
      search_field = Cud.sub_authority_table[sub_authority]
      q.split(" ").each do |word|
        query.push('%s:%s'% [search_field, word])
      end
      query.push('cud\:cas\:oxford_email_text:*')
      query = query.join(" AND ")
      query = URI.escape(query)
      return_fields="cud:cas:fullname,cud:cas:lastname,cud:cas:firstname,cud:cas:oxford_email,cud:cas:sso_username,cud:cas:current_affiliation"
      rows = 10 #This is not working
      query_url = "#{Sufia.config.cud_base_url}/cgi-bin/querycud.py?q=#{query}&fields=#{return_fields}&format=json"
      begin
        timeout(3) { @raw_response = get_json(query_url) }
      rescue
        @raw_response = {}
      end
      @response = parse_authority_response(@raw_response)
    end

    def self.all_fields
      @fields ||= 
        begin
          [
          'cud:cas:cudid',
          'cud:fk:university_card_sysis',
          'cud:fk:oss_student_number',
          'cud:fk:bodleian_record_number',
          'cud:fk:hris_staff_number',
          'cud:fk:oucs_pcode',
          'cud:fk:telecom_id',
          'cud:fk:careers_id',
          'cud:fk:dars_id',
          'cud:cas:title',
          'cud:cas:suffix',
          'cud:cas:fullname',
          'cud:cas:lastname',
          'cud:cas:firstname',
          'cud:cas:known_as',
          'cud:cas:initials',
          'cud:cas:middlenames',
          'cud:cas:oxford_email',
          'cud:cas:internal_tel',
          'cud:cas:sso_username',
          'cud:cas:current_affiliation',
          'cud:cas:university_card_status',
          'cud:cas:scoped_affiliation',
          'cud:cas:university_card_type',
          'cud:cas:course_code',
          'cud:cas:course_name',
          'cud:cas:course_year',
          'cud:cas:student_year',
          'cud:cas:barcode',
          'cud:consolidated:alternative_email',
          'cud:consolidated:dob',
          'cud:consolidated:gender',
          'cud:cas:external_tel',
          'cud:consolidated:external_email',
          'cud:consolidated:pas',
          'cud:consolidated:photo'
          ]
        end
    end

    def self.fields
      @fields ||= 
        begin
          {
          'cud:cas:cudid' => 'id',
          'cud:fk:hris_staff_number' => 'hris_staff_number',
          'cud:cas:title' => 'title',
          'cud:cas:suffix' => 'suffix',
          'cud:cas:fullname' => 'fullname',
          'cud:cas:lastname' => 'lastname',
          'cud:cas:firstname' => 'firstname',
          'cud:cas:known_as' => 'known_as',
          'cud:cas:initials' => 'initials',
          'cud:cas:middlenames' => 'middlenames',
          'cud:cas:oxford_email' => 'oxford_email',
          'cud:cas:internal_tel' => 'internal_tel',
          'cud:cas:sso_username' => 'sso_username',
          'cud:cas:current_affiliation' => 'current_affiliation',
          'cud:cas:university_card_status' => 'university_card_status',
          'cud:cas:scoped_affiliation' => 'scoped_affiliation',
          'cud:cas:university_card_type' => 'university_card_type',
          'cud:cas:course_code' => 'course_code',
          'cud:cas:course_name' => 'course_name',
          'cud:cas:course_year' => 'course_year',
          'cud:cas:student_year' => 'student_year',
          'cud:cas:barcode' => 'barcode',
          'cud:consolidated:alternative_email' => 'alternative_email',
          'cud:consolidated:dob' => 'dob',
          'cud:consolidated:gender' => 'gender',
          'cud:cas:external_tel' => 'external_tel',
          'cud:consolidated:external_email' => 'external_email',
          'cud:consolidated:photo' => 'photo'
          }
        end
    end

    def self.sub_authority_table
      @sub_authority_table ||=
        begin
          {
          'fullname' => 'cud\:cas\:fullname_text',
          'lastname' => 'cud\:cas\:lastname_text',
          'firstname' => 'cud\:cas\:firstname_text',
          'oxford_email' => 'cud\:cas\:oxford_email_text',
          'sso_username' => 'cud\:cas\:sso_username_text',
          'sso_username_exact' => 'cud\:cas\:sso_username',
          'current_affiliation' => 'cud\:cas\:current_affiliation'
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
      if !raw_response.keys.include?('cudSubjects')
        return ans
      end
      raw_response['cudSubjects'].each do |doc|
        ans.push(cud_response_to_qa(doc))
        if ans.length == 10 then
          break
        end
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

    # Conversion from cud hash to QA hash
    def cud_response_to_qa(data)
      resp = {}
      data['attributes'].each do |field|
        if Cud.fields.has_key?(field["name"])
          resp[Cud.fields[field["name"]]] = field["value"]
        end
      end
      # Data['attributes'] no longer has affiliation information. They are passed seperately
      aff = []
      if data.fetch('affiliations', nil) && data['affiliations'].any?
        data['affiliations'].each do |field|
          # field has the following keys - source, affiliation, status, startDate, endDate, lastUpdated, dateAdded
          # The affiliations have endDate. If endDate < today - 1 year, we should not use that affiliation
          endDate = Time.parse(field['endDate']["$date"]) rescue nil
          if field['source'] != "UAS_DARS" && endDate && endDate > Time.now.ago(1.year)
            aff.push(field["affiliation"])
          end
        end
      end
      if !aff.empty?
        val = aff.max_by(&:length)
        resp["current_affiliation"] = val
      else
        resp["current_affiliation"] = ""
      end
      #TODO: If there are no affiliations, we should not use that person
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

