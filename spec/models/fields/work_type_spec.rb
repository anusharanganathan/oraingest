require 'rails_helper'
require 'fields/work_type'

describe WorkType do
  def params
    {
        typeLabel: "Article",
        typeAuthority: Sufia.config.type_authorities['article']['Article']
    }.with_indifferent_access
  end

  describe  'building a worktype' do
    let(:model) { Article.new }

    it 'creates a worktype' do
      worktype = model.worktype.build(params)
      expect(worktype).to be_a(WorkType)
      expect(worktype.persisted?).to be false
      expect(worktype.id).to be_nil
    end

    it 'builds solr' do
      worktype = model.worktype.build(params)
      solr = worktype.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end
end