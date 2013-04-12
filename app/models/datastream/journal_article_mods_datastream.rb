# a Fedora Datastream object containing Mods XML for the descMetadata 
# datastream in the Journal Article hydra content type, defined using 
# ActiveFedora and OM.
require 'hydra-mods'

class JournalArticleModsDatastream < ActiveFedora::NokogiriDatastream
#class JournalArticleModsDatastream < ActiveFedora::OmDatastream
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3 http://ora.ox.ac.uk/access/mods-3.2-oxford.xsd")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:index_as=>[:facetable],:path=>"title", :label=>"title")
      t.sub_title(:index_as=>[:facetable],:path=>"subTitle", :label=>"subtitle")
    }

    t.abstract 

    t.journal(:path=>'relatedItem', :attributes=>{:type=>"host"}) {
      t.title_info(:ref=>[:title_info])
      t.issue(:path=>"part") {
        t.volume(:path=>"detail", :attributes=>{:type=>"volume"}, :default_content_path=>"number") 
        t.level(:path=>"detail", :attributes=>{:type=>"issue"}, :default_content_path=>"number", :label=>"issue")
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
    t.agent(:path=>"name", :attributes=>{:type=>"", :authority=>"http://www.bodleian.ox.ac.uk/ora/authority"}) {
      t.first_name(:path=>"namePart", :attributes=>{:type=>"given"})
      t.last_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.term_of_address(:path=>"namePart", :attributes=>{:type=>"termOfAddress"}, :label=>"term of address")
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

    t.type(:path=>"genre", :attributes=>{:type=>"typeofwork"})
    t.subtype(:path=>"genre", :attributes=>{:type=>"subtypeofwork"})
   
    t.origin_info(:path=>"originInfo") {
      t.date_issued(:path=>"dateIssued", :attributes=>{:encoding=>"iso8601"}, :label=>"publication date")
      t.copyright_date(:path=>"copyrightDate", :attributes=>{:encoding=>"iso8601"}, :label=>"copyright date")
    }

    t.language_text(:path=>"language"){
      t.text(:path=>"languageTerm", :attributes=>{:type=>"text", :authority=>"iso639-3"})
    }

    t.status(:path=>"form", :attributes=>{:type=>"status"}, :label=>"status")
    t.peer_reviewed(:path=>"form", :attributes=>{:type=>"peerReviewed"}, :label=>"peer reviewed")
    t.version(:path=>"form", :attributes=>{:type=>"version"}, :label=>"version")

    t.subject_parent(:path=>"subject"){
      t.topic(:path=>"topic", :label=>"subject")
      t.genre(:path=>"genre", :label=>"keyword")
    }

    t.license(:path=>"accessCondition", :attributes=>{:displayLabel=>"License"}, :label=>"license")

    t.identifier(:path=>"identifier", :attributes=>{:type=>""})
    t.local_id(:path=>"identifier", :attributes=>{:type=>"local"}, :label=>"local")
    t.doi(:path=>"identifier", :attributes=>{:type=>"doi"}, :label=>"doi")
    t.issn(:path=>"identifier", :attributes=>{:type=>"issn"}, :label=>"issn")
    t.eissn(:path=>"identifier", :attributes=>{:type=>"eissn"}, :label=>"eissn")
    t.publisher_id(:path=>"identifier", :attributes=>{:type=>"publisher"}, :label=>"publisher's copy" )
    t.barcode(:path=>"identifier", :attributes=>{:type=>"local", :displayLabel=>"Barcode"}, :label=>"barcode")
    t.pii(:path=>"identifier", :attributes=>{:type=>"pii"}, :label=>"publisher item identifier")
    t.article_number(:path=>"identifier", :attributes=>{:type=>"article_number"}, :label=>"article number")

    t.note
    t.publisher_note(:path=>"note", :attributes=>{:type=>"publisher"}, :label=>"publisher note")
    t.admin_note(:path=>"note", :attributes=>{:type=>"admin"}, :label=>"private note")

    t.related_item(:path=>"relatedItem", :attributes=>{:type=>""}){
      t.title_info(:ref=>[:title_info])
      t.location_url {
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
    t.journal_volume(:proxy=>[:journal, :issue, :volume])
    t.journal_issue(:proxy=>[:journal, :issue, :level])
    t.start_page(:proxy=>[:journal, :issue, :pages, :start])
    t.end_page(:proxy=>[:journal, :issue, :pages, :end])
    t.page_numbers(:proxy=>[:journal, :issue, :pages, :list])
    t.publication_date(:proxy=>[:origin_info, :date_issued])
    t.copyright_date(:proxy=>[:origin_info, :copyright_date])
    t.subject(:proxy=>[:subject_parent, :topic])
    t.keyword(:proxy=>[:subject_parent, :genre])
    t.lnguage(:proxy=>[:language_text, :text])

  end # set_terminology

  # This defines what the default xml should look like when you create empty MODS datastreams.
  # We are reusing the ModsArticle xml_template that Hydra provides, but you can make this method return any xml you desire.
  # See the API docs for more info. http://hudson.projecthydra.org/job/om/Documentation/OM/XML/Container/ClassMethods.html#xml_template-instance_method
  def self.xml_template
    return Hydra::Datastream::ModsArticle.xml_template
  end

end # class
