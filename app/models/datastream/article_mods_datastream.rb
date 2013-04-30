# a Fedora Datastream object containing Mods XML for the descMetadata 
# datastream in the Journal Article hydra content type, defined using 
# ActiveFedora and OM.
require 'hydra-mods'

class ArticleModsDatastream < ActiveFedora::NokogiriDatastream
#class ArticleModsDatastream < ActiveFedora::OmDatastream
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3 http://ora.ox.ac.uk/access/mods-3.2-oxford.xsd")
    t.pid(:path=>"identifier", :attributes=>{:type=>"pid"}, :label=>"PID")
    t.urn(:path=>"identifier", :attributes=>{:type=>"urn"}, :label=>"urn")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:index_as=>[:facetable],:path=>"title", :label=>"title")
      t.sub_title(:index_as=>[:facetable],:path=>"subTitle", :label=>"subtitle")
    }

    t.abstract 

    t.journal(:path=>'relatedItem', :attributes=>{:type=>"host"}) {
      t.title_info(:ref=>[:title_info])
      t.part {
        #t.volume(:path=>"detail", :attributes=>{:type=>"volume"}, :default_content_path=>"number") 
        t.volume(:path=>"detail", :attributes=>{:type=>"volume"}) {
          t.number
        }
        #t.issue(:path=>"detail", :attributes=>{:type=>"issue"}, :default_content_path=>"number")
        t.issue(:path=>"detail", :attributes=>{:type=>"issue"}){
          t.number
        }
        t.pages(:path=>"extent", :attributes=>{:unit=>"pages"}) {
          t.list
          t.start
          t.end
        }
        #t.start_page(:proxy=>[:pages, :start])
        #t.end_page(:proxy=>[:pages, :end])
        #t.page(:proxy=>[:pages, :list])
      }
    }

    #t.agent(:path=>"name", :attributes=>{:type=>["personal", "corporate", ""], :authority=>"http://www.bodleian.ox.ac.uk/ora/authority"}) {
    t.agent(:path=>"name", :attributes=>{:authority=>"http://www.bodleian.ox.ac.uk/ora/authority"}) {
      t.first_name(:path=>"namePart", :attributes=>{:type=>"given"})
      t.last_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"}, :label=>"terms of address")
      t.display_name(:path=>"displayForm", :label=>"display form of name")
      t.roleterm(:path=>"role", :label=>"role"){
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
      }
      t.role(:proxy=>[:roleterm, :text])
      t.webauth(:path=>"identifier", :attributes=>{:type=>"webauth"})
      t.pid(:path=>"identifier", :attributes=>{:type=>"urn"}, :label=>"pid")
      t.institution(:path=>"affiliation", :attributes=>{:type=>"institution"})
      t.faculty(:path=>"affiliation", :attributes=>{:type=>"faculty"})
      t.research_group(:path=>"affiliation", :attributes=>{:type=>"researchGroup"}, :label=>"research group")
      t.oxford_college(:path=>"affiliation", :attributes=>{:type=>"oxfordCollege"}, :label=>"college")
      t.affiliation
      t.funder(:path=>"affiliation", :attributes=>{:type=>"funding"})
      t.grant_number(:path=>"affiliation", :attributes=>{:type=>"grantNumber"}, :label=>"grant number")
      t.website(:path=>"affiliation", :attributes=>{:type=>"website"})
      t.email(:path=>"affiliation", :attributes=>{:type=>"email"})
      t.rights_ownership(:path=>"affiliation", :attributes=>{:type=>"rightsOwnership"}, :label=>"rights ownership")
      t.third_party_copyright(:path=>"affiliation", :attributes=>{:type=>"ThirdPartyCopyright"}, :label=>"third party copyright")
    }
    t.person(:ref=>:agent, :attributes=>{:type=>"personal"}, :index_as=>[:facetable])
    t.organisation(:ref=>:agent, :attributes=>{:type=>"corporate"}, :index_as=>[:facetable])
    t.copyright_holder(:ref=>:agent, :index_as=>[:facetable])

    t.type(:path=>"genre", :attributes=>{:type=>"typeofwork"})
    t.subtype(:path=>"genre", :attributes=>{:type=>"subtypeofwork"})
   
    t.origin_info(:path=>"originInfo") {
      t.date_issued(:path=>"dateIssued", :attributes=>{:encoding=>"iso8601"}, :label=>"publication date")
      t.date_created(:path=>"dateCreated", :attributes=>{:encoding=>"iso8601"}, :label=>"creation date")
      t.copyright_date(:path=>"copyrightDate", :attributes=>{:encoding=>"iso8601"}, :label=>"copyright date")
    }

    t.language_text(:path=>"language"){
      t.text(:path=>"languageTerm", :attributes=>{:type=>"text", :authority=>"iso639-3"})
    }
    t.physical_description(:path=>"physicalDescription"){
      t.status(:path=>"form", :attributes=>{:type=>"status"}, :label=>"status")
      t.peer_reviewed(:path=>"form", :attributes=>{:type=>"peerReviewed"}, :label=>"peer reviewed")
      t.version(:path=>"form", :attributes=>{:type=>"version"}, :label=>"version")
    }

    t.subject_parent(:path=>"subject"){
      t.topic(:path=>"topic", :label=>"subject")
      t.genre(:path=>"genre", :label=>"keyword")
    }

    t.license(:path=>"accessCondition", :attributes=>{:type=>"restrictionOnAccess"}, :label=>"license")

    t.identifier(:path=>"identifier", :attributes=>{:type=>""})
    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :label=>"local")
    t.doi(:path=>"identifier", :attributes=>{:type=>"doi"}, :label=>"DOI")
    t.issn(:path=>"identifier", :attributes=>{:type=>"issn"}, :label=>"ISSN")
    t.eissn(:path=>"identifier", :attributes=>{:type=>"eissn"}, :label=>"eISSN")
    t.publisher_id(:path=>"identifier", :attributes=>{:type=>"publisher"}, :label=>"publisher's copy" )
    t.barcode(:path=>"identifier", :attributes=>{:type=>"local", :displayLabel=>"Barcode"}, :label=>"barcode")
    t.pii(:path=>"identifier", :attributes=>{:type=>"pii"}, :label=>"publisher item identifier")
    t.article_number(:path=>"identifier", :attributes=>{:type=>"article_number"}, :label=>"article number")

    t.note
    t.publisher_note(:path=>"note", :attributes=>{:type=>"publisher"}, :label=>"publisher note")
    t.admin_note(:path=>"note", :attributes=>{:type=>"admin"}, :label=>"private note")

    t.related_item(:path=>"relatedItem", :attributes=>{:type=>""}){
      t.title_info(:ref=>[:title_info])
      t.location_url(:path=>"location"){
        t.url
      }
      t.location(:proxy=>[:location_url, :url])
      t.name
    }
 
    # these proxy declarations allow you to use more familiar term/field names that hide the details of the XML structure
    t.title(:proxy=>[:mods, :title_info, :main_title])
    t.subtitle(:proxy=>[:mods, :title_info, :sub_title])
    t.journal_title(:proxy=>[:journal, :title_info, :main_title])
    #t.journal_volume(:proxy=>[:journal, :issue, :volume, :number])
    #t.journal_issue(:proxy=>[:journal, :issue, :level, :number])
    t.journal_volume(:proxy=>[:journal, :part, :volume, :number])
    t.journal_issue(:proxy=>[:journal, :part, :issue, :number])
    t.start_page(:proxy=>[:journal, :part, :pages, :start])
    t.end_page(:proxy=>[:journal, :part, :pages, :end])
    t.page_numbers(:proxy=>[:journal, :part, :pages, :list])
    t.publication_date(:proxy=>[:origin_info, :date_issued])
    t.creation_date(:proxy=>[:origin_info, :date_created])
    t.copyright_date(:proxy=>[:origin_info, :copyright_date])
    t.subject(:proxy=>[:subject_parent, :topic])
    t.keyword(:proxy=>[:subject_parent, :genre])
    t.language(:proxy=>[:language_text, :text])
  end # set_terminology

  # This defines what the default xml should look like when you create empty MODS datastreams.
  # We are reusing the ModsArticle xml_template that Hydra provides, but you can make this method return any xml you desire.
  # See the API docs for more info. http://hudson.projecthydra.org/job/om/Documentation/OM/XML/Container/ClassMethods.html#xml_template-instance_method
  def self.xml_template
    #return Hydra::Datastream::ModsArticle.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods(:version=>"3.3", "xmlns:xlink"=>"http://www.w3.org/1999/xlink",
             "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
             "xmlns"=>"http://www.loc.gov/mods/v3",
             "xsi:schemaLocation"=>"http://www.loc.gov/standards/mods/v3 http://ora.ox.ac.uk/access/mods-3.2-oxford.xsd") {
        xml.identifier(:type=>"pid")
        xml.titleInfo {
          xml.title
        }
        xml.name(:type=>"personal", :authority=>"http://www.bodleian.ox.ac.uk/ora/authority") {
          xml.namePart(:type=>"given")
          xml.namePart(:type=>"family")
          xml.displayForm
          xml.role {
            xml.roleTerm("Author", :type=>"text")
          }
        }
        xml.relatedItem(:type=>"host") {
          xml.titleInfo {
            xml.title
          }
          #xml.part {
          #  xml.detail(:type=>"volume") {
          #    xml.number
          #  }
          #  xml.detail(:type=>"number") {
          #    xml.number
          #  }
          #  xml.extent(:unit=>"pages") {
          #    xml.list
          #  }
        }
        xml.originInfo {
          xml.dateIssued(:encoding=>"iso8601")
        }
        xml.physicalDescription {
          xml.form(:type=>"status")
          xml.form(:type=>"peerReviewed")
          xml.form(:type=>"version")
        }
        xml.language {
          xml.languageTerm(:authority=>"iso639-3")
        }
        xml.accessCondition(:displayLabel=>"License")
        xml.name(:authority=>"http://www.bodleian.ox.ac.uk/ora/authority") {
          xml.namePart(:type=>"given")
          xml.namePart(:type=>"family")
          xml.displayForm
          xml.role {
            xml.roleTerm("Copyright Holder", :type=>"text")
          }
          xml.affiliation(:type=>"rightsOwnership")
          #xml.affiliation(:type=>"ThirdPartyCopyright")
        }
      }
    end
    return builder.doc
  end # xml_template

  # Generates a new Person node
  def self.person_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.name(:type=>"personal") {
        xml.namePart(:type=>"family")
        xml.namePart(:type=>"given")
        xml.namePart(:type=>"termOfAddress")
        xml.displayForm
        xml.role {
          xml.roleTerm(:type=>"text")
        }
        xml.identifier(:type=>"webauth")
        xml.identifier(:type=>"urn")
        xml.identifier(:type=>"pid")
        xml.affiliation
        xml.affiliation(:type=>"institution")
        xml.affiliation(:type=>"faculty")
        xml.affiliation(:type=>"researchGroup")
        xml.affiliation(:type=>"oxfordCollege")
        xml.affiliation(:type=>"funding")
        xml.affiliation(:type=>"grantNumber")
        xml.affiliation(:type=>"website")
        xml.affiliation(:type=>"email")
      }
    end
    return builder.doc.root
  end # person_template

  # Generates a new organisation node
  def self.organization_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.name(:type=>"corporate") {
        xml.displayForm
        xml.role {
          xml.roleTerm(:type=>"text")
        }
        xml.affiliation(:type=>"grantNumber")
        xml.affiliation(:type=>"website")
      }
    end
    return builder.doc.root
  end # organization_template

  # Generates a new copyright holder node
  def self.copyright_holder_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.name {
        xml.namePart(:type=>"family")
        xml.namePart(:type=>"given")
        xml.namePart(:type=>"termOfAddress")
        xml.displayForm
        xml.role {
          xml.roleTerm("Copyright Holder", :type=>"text")
        }
        xml.identifier(:type=>"pid")
        xml.affiliation(:type=>"rightsOwnership")
        xml.affiliation(:type=>"ThirdPartyCopyright")
      }
    end
    return builder.doc.root
  end # copyright_holder_template

  # Inserts a new contributor (mods:name) into the mods document
  # creates contributors of type :person, :organization, or :conference
  def insert_agent(type, opts={})
    case type.to_sym
    when :person
      node = ArticleModsDatastream.person_template
      nodeset = self.find_by_terms(:person)
    when :organization
      node = ArticleModsDatastream.organization_template
      nodeset = self.find_by_terms(:organization)
    when :copyright_holder
      node = ArticleModsDatastream.copyright_holder_template
      nodeset = self.find_by_terms(:copyright_holder)
    else
      ActiveFedora.logger.warn("#{type} is not a valid argument for ArticleModsDatastream.insert_agent")
      node = nil
      index = nil
    end
        
    unless nodeset.nil?
      if nodeset.empty?
        self.ng_xml.root.add_child(node)
        index = 0
      else
        nodeset.after(node)
        index = nodeset.length
      end
      self.dirty = true
    end
        
    return node, index
  end #insert_agent

  # Remove the contributor entry identified by @contributor_type and @index
  def remove_agent(contributor_type, index)
    contributor = self.find_by_terms( {contributor_type.to_sym => index.to_i} ).first
    unless contributor.nil?
      contributor.remove
      self.dirty = true
    end
  end #remove_agent
      
end # class
