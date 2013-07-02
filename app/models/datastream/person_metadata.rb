require "./article_mods_datastream.rb"
class Person
  set_terminology do |t|
    t.person(:path=>"name", :attributes=>{:authority=>"http://www.bodleian.ox.ac.uk/ora/authority", :type=>"personal"}, :index_as=>[:facetable]) {
      t.first_name(:path=>"namePart", :attributes=>{:type=>"given"})
      t.last_name(:path=>"namePart", :attributes=>{:type=>"family"})
      t.terms_of_address(:path=>"namePart", :attributes=>{:type=>"termsOfAddress"}, :label=>"terms of address")
      t.display_name(:path=>"displayForm", :label=>"display form of name")
      t.roleterm(:path=>"role"){
        t.text(:path=>"roleTerm",:attributes=>{:type=>"text"}, :label=>"role")
      }
      t.webauth(:path=>"identifier", :attributes=>{:type=>"webauth"})
      t.uuid(:ref=>[:uuid])
      t.affiliation
      t.institution(:path=>"affiliation", :attributes=>{:type=>"institution"}, :label=>"institution")
      t.faculty(:path=>"affiliation", :attributes=>{:type=>"faculty"}, :label=>"faculty")
      t.research_group(:path=>"affiliation", :attributes=>{:type=>"researchGroup"}, :label=>"research group")
      t.oxford_college(:path=>"affiliation", :attributes=>{:type=>"oxfordCollege"}, :label=>"college")
      t.funder(:path=>"affiliation", :attributes=>{:type=>"funding"}, :label=>"funder")
      t.grant_number(:path=>"affiliation", :attributes=>{:type=>"grantNumber"}, :label=>"grant number")
      t.website(:path=>"affiliation", :attributes=>{:type=>"website"}, :label=>"website")
      t.email(:path=>"affiliation", :attributes=>{:type=>"email"}, :label=>"email")
    }
    end # set_terminology
    belongs_to Datastream::ArticleModsDatastream
 end

