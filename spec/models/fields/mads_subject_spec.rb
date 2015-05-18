require 'rails_helper'
require 'fields/mads_subject'

describe MadsSubject do

  def params
    {
        subjectLabel: 'Subject #1',
        subjectAuthority: 'Authority',
        subjectScheme: 'scheme'
    }
  end

  describe  'building a subject' do
    let(:model) { Article.new }

    it 'creates a subject' do
      subject = model.subject.build(params)
      expect(subject).to be_a(MadsSubject)
      expect(subject.persisted?).to be false
      expect(subject.id).to be_nil
    end

    it 'builds solr' do
      subject = model.subject.build(params)
      solr = subject.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end
end