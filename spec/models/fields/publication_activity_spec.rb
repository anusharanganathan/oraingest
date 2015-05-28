require 'rails_helper'
require 'fields/publication_activity'

describe PublicationActivity do
  def params
    {
        'publicationStatus' => nil, 
        'reviewStatus' => nil, 
        'publisher_attributes' =>  {
            '0' =>  {
                'agent_attributes' =>  {
                    '0' =>  {
                        'name' => '', 
                        'website' => ''
                    }
                }
            }
        }, 
        'dateAccepted' => '2014-12-01',
        'datePublished' => '2015-02-23',
        'location' => nil, 
        'hasDocument_attributes' =>  {
            '0' =>  {
                'doi' => '10.5072/bodleian:nn999n999', 
                'uri' => '', 
                'identifier' => '', 
                'series_attributes' =>  {
                    '0' =>  {
                        'title' => ''
                    }
                }, 
                'journal_attributes' =>  { 
                    '0' =>  {
                        'title' => '', 
                        'issn' => '', 
                        'eissn' => '', 
                        'volume' => '', 
                        'issue' => '', 
                        'pages' => ''
                    }
                }
            }
        }, 
        'id' => 'info:fedora/#publicationActivity', 
        'type' => RDF::PROV.Activity, 
        'wasAssociatedWith' => []
    }
  end

  describe  'building a publication activity' do

    let(:model) { Article.new }

    it 'creates a publication activity' do
      activity = model.publication.build(params)
      expect(activity).to be_a(PublicationActivity)
      expect(activity.persisted?).to be true
      expect(activity.id).not_to be_nil
    end

    it 'builds solr' do
      activity = model.publication.build(params)
      solr = activity.to_solr({})
      expect(solr).to be_a(Hash)
    end

  end
end