require 'rails_helper'
require 'fields/location'

describe Location do

  def params
    {
        value: 'UK'
    }
  end

  describe  'building a location' do
    let(:model) { Dataset.new }

    it 'creates a location' do
      location = model.spatial.build(params)
      expect(location).to be_a(Location)
      expect(location.persisted?).to be false
      expect(location.id).to be_nil
    end
  end
end