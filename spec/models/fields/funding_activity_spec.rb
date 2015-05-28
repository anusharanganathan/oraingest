require 'rails_helper'
require 'fields/funding_activity'

describe FundingActivity do

  def params
    {
        wasAssociatedWith: ['info:fedora/#funder0'],
        hasFundingAward: 'yes'
    }
  end

  describe  'building a funding activity' do
    let(:model) { Article.new }

    it 'creates a funding activity' do
      activity = model.funding.build(params)
      expect(activity).to be_a(FundingActivity)
      expect(activity.persisted?).to be false
      expect(activity.id).to be_nil
    end

    it 'builds solr' do
      activity = model.funding.build(params)
      solr = activity.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end

end