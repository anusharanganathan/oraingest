require 'rails_helper'
require 'fields/titular_activity'

describe TitularActivity do

  def params
    {
        id: 'info:fedora/#titularActivity', 
        wasAssociatedWith: ['info:fedora/#titular0'], 
        type: RDF::PROV.Activity
    }
  end

  describe  'building a titular activity' do
    let(:model) { DatasetAgreement.new }

    it 'creates a titular activity' do
      activity = model.titularActivity.build(params)
      expect(activity).to be_a(TitularActivity)
      expect(activity.persisted?).to be false
      expect(activity.id).to be_nil
    end

    it 'builds solr' do
      activity = model.titularActivity.build(params)
      solr = activity.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end
end