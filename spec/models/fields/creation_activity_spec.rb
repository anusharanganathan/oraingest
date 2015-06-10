require 'rails_helper'
require 'fields/creation_activity'

describe CreationActivity do

  def params
    {
        id: 'info:fedora/#creationActivity',
        wasAssociatedWith: ['info:fedora/#creator0'],
        type: RDF::PROV.Activity
    }
  end

  describe  'building a creation activity' do
    let(:model) { Article.new }

    it 'creates a creation activity' do
      activity = model.creation.build(params)
      expect(activity).to be_a(CreationActivity)
      expect(activity.persisted?).to be false
      expect(activity.id).to be_nil
    end

    it 'builds solr' do
      activity = model.creation.build(params)
      solr = activity.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end
end