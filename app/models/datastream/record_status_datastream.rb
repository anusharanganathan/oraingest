# a Fedora Datastream object containing Mods XML for the descMetadata 
# datastream in the Journal Article hydra content type, defined using 
# ActiveFedora and OM.
class Datastream::RecordStatusDatastream < ActiveFedora::OmDatastream
#class RecordStatusDatastream < ActiveFedora::NokogiriDatastream
#class ArticleModsDatastream < ActiveFedora::OmDatastream
  # OM (Opinionated Metadata) terminology mapping for the mods xml
  set_terminology do |t|
    t.root(:path=>"fields")
    t.date_modified(:path=>"dateModified", :label=>"date modified")

    t.record {
      t.date
      t.status(:index_as=>[:facetable])
      t.reviewer {
          t.name(:index_as=>[:facetable])
          t.webauth
      }
      t.note
      t.reviewer_name(:proxy=>[:reviewer,:name])
      t.reviewer_id(:proxy=>[:reviewer,:webauth])
    }
  end # set_terminology

  # This defines what the default xml should look like when you create empty MODS datastreams.
  # We are reusing the ModsArticle xml_template that Hydra provides, but you can make this method return any xml you desire.
  # See the API docs for more info. http://hudson.projecthydra.org/job/om/Documentation/OM/XML/Container/ClassMethods.html#xml_template-instance_method
  def self.xml_template
    #return Hydra::Datastream::ModsArticle.xml_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.fields() {
        xml.dateModified
        xml.record {
          xml.date
          xml.status
          xml.reviewer {
            xml.name
            xml.webauth
          }
        }
      }
    end
    return builder.doc
  end # xml_template

  # Generates a new status node
  def self.status_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.record {
        xml.date
        xml.status
        xml.reviewer {
          xml.name
          xml.webauth
        }
      }
    end
    return builder.doc.root
  end # status_template

  # Remove the status entry identified by @status_type and @index
  def remove_status(status_type, index)
    status = self.find_by_terms( {status_type.to_sym => index.to_i} ).first
    unless status.nil?
      status.remove
      self.dirty = true
    end
  end #remove_status
      
end # class
