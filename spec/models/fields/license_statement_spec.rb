require 'rails_helper'
require 'fields/rights_activity'

describe LicenseStatement do

  def params
    {
        licenseLabel: 'Open Government Licence (OGL)',
        licenseStatement: 'Licence statement',
        licenseURI: ' http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/',
        id: 'info:fedora/#license'
    }.with_indifferent_access
  end

  describe  'building a license statement' do
    let(:model) { Article.new }

    it 'creates a license statement' do
      license = model.license.build(params)
      expect(license).to be_a(LicenseStatement)
      expect(license.persisted?).to be true
      expect(license.id).not_to be_nil
    end

    it 'builds solr' do
      license = model.license.build(params)
      solr = license.to_solr({})
      expect(solr).to be_a(Hash)
    end
  end
end