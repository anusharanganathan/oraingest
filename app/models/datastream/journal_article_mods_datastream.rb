# a Fedora Datastream object containing Mods XML for the descMetadata 
# datastream in the Journal Article hydra content type, defined using 
# ActiveFedora and OM.
class JournalArticleModsDatastream < ActiveFedora::NokogiriDatastream
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")
    t.title_info(:path=>"titleInfo") {
      t.main_title(:index_as=>[:facetable],:path=>"title", :label=>"title")
    }
    t.author(:path=>"name", :attributes=>{:type=>"personal"}) {
      t.first_name(:path=>"namePart", :attributes=>{:type=>"given"})
      t.last_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.role {
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"})
      }
    }
    t.abstract 
    t.journal(:path=>'relatedItem', :attributes=>{:type=>"host"}) {
      t.title_info(:ref=>[:title_info])
      t.issue(:path=>"part") {
        t.volume(:path=>"detail", :attributes=>{:type=>"volume"}) {
          t.number
        }
        t.level(:path=>"detail", :attributes=>{:type=>"level"}) {
          t.number
        }
        t.pages(:path=>"extent", :attributes=>{:unit=>"pages"}) {
          t.start
          t.end
        }
        t.date
      }
    }
      
    # these proxy declarations allow you to use more familiar term/field names that hide the details of the XML structure
    t.title(:proxy=>[:mods, :title_info, :main_title])
    t.journal_title(:proxy=>[:journal, :title_info, :main_title])
    t.journal_volume(:proxy=>[:journal, :issue, :volume, :number])
    t.journal_issue(:proxy=>[:journal, :issue, :level, :number])
    t.start_page(:proxy=>[:journal, :issue, :pages, :start])
    t.end_page(:proxy=>[:journal, :issue, :pages, :end])
    t.publication_date(:proxy=>[:journal, :issue, :date])

  end # set_terminology

  # This defines what the default xml should look like when you create empty MODS datastreams.
  # We are reusing the ModsArticle xml_template that Hydra provides, but you can make this method return any xml you desire.
  # See the API docs for more info. http://hudson.projecthydra.org/job/om/Documentation/OM/XML/Container/ClassMethods.html#xml_template-instance_method
  def self.xml_template
    #return Hydra::Datastream::ModsArticle.xml_template
    return Hydra::Datastream::Properties.xml_template
  end

end # class
