require 'uri'
require 'rest_client'
require 'active_support/core_ext/hash/indifferent_access'
require 'builder'
require 'nokogiri'

module ORA
   class DataValidationError < RuntimeError
      def initialize(errors)
        if errors.is_a?(Array)
          super(errors.join(". ") << '.')
        else
          super(errors)
        end
      end
    end

    class DataDoi
      TEST_CONFIGURATION =
      {
        username: 'apitest',
        password: 'apitest',
        shoulder: 'doi:10.5072/FK2',
        resolver_url: 'http://dx.doi.org/'
      }

      attr_reader :username, :password, :shoulder, :resolver_url
      def initialize(options = {})
        configuration = options.with_indifferent_access
        @username = configuration.fetch(:username)
        @password = configuration.fetch(:password)
        @shoulder = configuration.fetch(:shoulder)
        @url = configuration.fetch(:url)
        @resolver_url = configuration.fetch(:resolver_url) { default_resolver_url }
        @resource = RestClient::Resource.new(@url, :user => @username, :password => @password)
      end

      def normalize_identifier(value)
        value.to_s.strip.
          sub(/\A#{resolver_url}/, '').
          sub(/\A\s*doi:\s+/, 'doi:').
          sub(/\A(\d)/, 'doi:\1')
      end

      def remote_uri_for(identifier)
        URI.parse(File.join(resolver_url, normalize_identifier(identifier)))
      end

      REQUIRED_ATTRIBUTES = ['identifier', 'creator', 'title', 'publisher', 'publicationYear' ].freeze
      def valid_attribute?(attribute_name)
        REQUIRED_ATTRIBUTES.include?(attribute_name.to_s)
      end

      def call(payload)
        request(data_for_create(payload.with_indifferent_access))
        add_metadata(to_xml(payload))
      end

      def validate_required(payload)
        payload = payload.with_indifferent_access
        errors = []
        REQUIRED_ATTRIBUTES.each do |attr|
          if !(payload.has_key?(attr) && !payload[attr].blank?)
            errors << "#{attr}"
          end
        end
        if errors.any?
          errors = "The following attributes are missing: " + errors.join(", ")
          raise DataValidationError.new(errors)
        end
      end

      def validate_xml(payload)
        payload = to_xml(payload)
        xsd = Nokogiri::XML::Schema(File.open(Rails.root + 'app/assets/xsd/datacite-metadata-v3.1.xsd'))
        document = Nokogiri::XML(payload)
        error = xsd.validate(document)
        raise DataValidationError.new(error) if error.any?
      end

      def to_xml(payload)
        data_for_metadata(payload.with_indifferent_access)
      end

      private

      def request(data)
        response = @resource['doi'].post(data, content_type: 'text/plain;charset=UTF-8')
        puts response.body, response.code
        matched_data = /\Asuccess:(.*)(?<doi>doi:[^\|]*)(.*)\Z/.match(response.body)
        matched_data[:doi].strip
      end

      def add_metadata(data)
        response = @resource['metadata'].post(data, content_type: 'application/xml;charset=UTF-8')
        puts response.body, response.code
        matched_data = /\Asuccess:(.*)(?<doi>doi:[^\|]*)(.*)\Z/.match(response.body)
        matched_data[:doi].strip
      end

      def data_for_create(payload)
        data = []
        data << "doi=#{payload[:identifier]}"
        data << "url=#{payload[:target]}"
        data.join("\n")
      end

      def data_for_metadata(payload)
        data = Builder::XmlMarkup.new( :indent => 2 )
        data.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        opts = {
          "xsi:schemaLocation"=>"http://datacite.org/schema/kernel-3 http://schema.datacite.org/meta/kernel-3/metadata.xsd",
          "xmlns"=>"http://datacite.org/schema/kernel-3",
          "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance"
        }
        data.resource( opts ) do
          # identifier
          data.tag!("identifier", payload[:identifier], :identifierType => "DOI")
          # creators
          data.creators do
            payload[:creator].each do |creator|
              data.creator do
                if creator.kind_of?(String)
                  data.creatorName creator
                else
                  data.creatorName creator[:name]
                  if creator.has_key?(:nameIdentifierScheme) && creator.has_key?(:nameIdentifierSchemeUri)
                    data.tag!("nameIdentifier", nameIdentifierScheme: creator[:nameIdentifierScheme], schemeURI: creator[:nameIdentifierSchemeUri])
                  end
                  if creator.has_key?(:affiliation)
                    data.affiliation creator[:affiliation]
                  end
                end
              end
            end
          end
          # titles
          data.titles do
            if payload[:title].is_a?(Hash)
              payload[:title] = [payload.title]
            end
            if payload[:title].is_a?(Array)
              payload[:title].each do |t|
                if t.kind_of?(String)
                  data.title t
                else
                  if t.has_key?(:type)
                    data.tag!("title", t[:title], titleType: t[:type])
                  else
                    data.title t[:title]
                  end
                end
              end
            else
              data.title payload[:title]
            end
          end
          # publisher
          data.publisher payload[:publisher]
          # publication uear
          data.publicationYear payload[:publicationYear]
          # subjects
          if payload.has_key?(:subject) && payload[:subject].length > 0
            data.subjects do
              payload[:subject].each do |s|
                if s.has_key?(:scheme) && s[:scheme] && s.has_key?(:schemeUri) && s[:schemeUri]
                  data.tag!("subject", s[:subject], subjectScheme: s[:scheme], schemeURI: s[:schemeUri])
                else
                  data.subject s[:subject]
                end
              end
            end
          end
          # Contributors
          if payload.has_key?(:contributor) && payload[:contributor].length > 0
            data.contributors do
              #TODO: Contributor type has to be one of accepted type if not other
              payload[:contributor].each do |contributor|
                if contributor.has_key?(:type)
                  typ = contributor[:type]
                else
                  typ = ""
                end
                data.contributor(contributorType: typ) do
                  if contributor.kind_of?(String)
                    data.contributorName contributor
                  else
                    data.contributorName contributor[:name]
                    if contributor.has_key?(:nameIdentifierScheme) && contributor.has_key?(:nameIdentifierSchemeUri)
                      data.tag!("nameIdentifier", nameIdentifierScheme: contributor[:nameIdentifierScheme], schemeURI: contributor[:nameIdentifierSchemeUri])
                    end
                    if contributor.has_key?(:affiliation)
                      data.affiliation contributor[:affiliation]
                    end
                  end
                end
              end
            end
          end   
          # resource type
          if payload.has_key?(:resourceType) && !payload[:resourceType].empty? && payload.has_key?(:resourceTypeGeneral) && !payload[:resourceTypeGeneral].empty?
            data.tag!("resourceType", payload[:resourceType], resourceTypeGeneral: payload[:resourceTypeGeneral])
          end
          # size
          if payload.has_key?(:size)
            data.sizes do
              if payload[:size].is_a?(Array)
                payload[:size].each do |s|
                  data.size s
                end
              else
                data.size payload[:size]
              end
            end
          end
          # format
          if payload.has_key?(:format)
            data.format do
              if payload[:format].is_a?(Array)
                payload[:format].each do |f|
                  data.format f
                end
              else
                data.format payload[:format]
              end
            end
          end
          # version
          if payload.has_key?(:version)
            data.version payload[:version]
          end
          # rights
          if payload.has_key?(:rights)
            data.rightsList do
              payload[:rights].each do |r|
                if r.has_key?(:rights) and r.has_key?(:rightsUri)
                  data.tag!("rights", r[:rights], rightsURI: r[:rightsUri])
                elsif r.has_key?(:rights)
                  data.tag!("rights", r[:rights])
                elsif r.has_key?(:rightsUri)
                  data.tag!("rights", rightsURI: r[:rightsUri] )
                end
              end
            end
          end
          # descriptions
          if payload.has_key?(:description)
            data.descriptions do
              payload[:description].each do |d|
                if d.has_key?(:description) and d.has_key?(:type)
                  data.tag!("description", d[:description], descriptionType: d[:type] )
                end
              end
            end
          end
        end
        data.target!
      end

      def default_resolver_url
        'http://dx.doi.org/'
      end

    end
end
