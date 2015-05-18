require 'rails_helper'
require 'fields/date_duration'

describe DateDuration do

  def params
    {
        start: '1979',
        end: '1990'
    }
  end

  describe  'building a duration' do
    let(:model) { Dataset.new }

    it 'creates a duration' do
      temporal = model.temporal.build(params)
      expect(temporal).to be_a(DateDuration)
      expect(temporal.persisted?).to be false
      expect(temporal.id).to be_nil
    end
  end
end