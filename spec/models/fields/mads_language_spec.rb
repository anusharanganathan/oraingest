require 'rails_helper'
require 'fields/mads_language'

describe MadsLanguage do

  def params
    {
        languageLabel: 'English',
        languageCode: 'eng',
        languageAuthority: nil,
        languageScheme: nil,
        id: "info:fedora/#{model.id}#language"
    }.with_indifferent_access
  end

  describe  'building a language' do
    let(:model) { Article.new }

    it 'creates a language' do
      language = model.language.build(params)
      expect(language).to be_a(MadsLanguage)
      expect(language.persisted?).to be true
      expect(language.id).not_to be_nil
    end

    it 'builds solr' do
      language = model.language.build(params)
      solr = language.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end
end

