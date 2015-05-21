require 'rails_helper'

describe 'embargo_date' do

  context 'Open access' do
    it 'returns a Hash of validated data' do
      params = {
          embargoStatus: 'Open access',
          embargoDate: {
              start: {date: '', label: ''},
              duration: {years: '', months: ''},
              end: {date: '', label: ''}
          },
          embargoReason:  '',
          embargoRelease: ''
      }

      result = Ora.validateEmbargoDates(params, 'uuid:nn999n999', nil)

      expect(result).to be_a(Hash)
      expect(result['id']).to eq('uuid:nn999n999#accessRights')
      expect(result[:embargoStatus]).to eq('Open access')
    end
  end

  context 'Closed access' do
    it 'returns a Hash of validated data' do
      params = {
          embargoStatus: 'Closed access',
          embargoDate: {
              start: {date: '', label: 'Today'},
              duration: {years: '', months: ''},
              end: {date: '12-02-1978', label: ''}
          },
          embargoReason: ['Ethical conditions or agreements'],
          embargoRelease: 'Automatically lift the embargo'
      }

      result = Ora.validateEmbargoDates(params, 'uuid:nn999n999', nil)

      expect(result).to be_a(Hash)
      expect(result['id']).to eq('uuid:nn999n999#accessRights')
      expect(result[:embargoStatus]).to eq('Closed access')
    end
  end

  context 'Embargoed' do

    context 'embargoed to specified end date' do
      it 'returns a Hash of validated data' do
        params = {
            embargoStatus: 'Embargoed',
            embargoDate: {
                start: {date: '', label: 'Today'},
                duration: {years: '', months: ''},
                end: {date: '12-02-1978', label: 'Stated'}
            },
            embargoReason: ['Ethical conditions or agreements'],
            embargoRelease: 'Automatically lift the embargo'
        }

        result = Ora.validateEmbargoDates(params, 'uuid:nn999n999', nil)

        expect(result).to be_a(Hash)
        expect(result[:embargoStatus]).to eq('Embargoed')
        expect(result[:embargoDate]).to be_an(Array)
        expect(result[:embargoDate]).not_to be_empty
        embargo_date = result[:embargoDate].first
        expect(embargo_date['id']).to eq('uuid:nn999n999#embargoDate')
        expect(embargo_date[:start]).to eq([{:date => nil, :label => nil, 'id' => nil}])
        expect(embargo_date[:duration]).to eq([{:years => nil, :months => nil, 'id' => nil}])
        expect(embargo_date[:end]).to eq([{:date => '12 Feb 1978', :label => 'Stated', 'id' => 'uuid:nn999n999#embargoEnd'}])
        expect(result[:embargoReason]).to eq(['Ethical conditions or agreements'])
        expect(result[:embargoRelease]).to eq('Automatically lift the embargo')

      end
    end

    context 'embargoed from today for a given duration with month and year defined' do

      before(:each) do
        Timecop.freeze
      end

      after(:each) do
        Timecop.return
      end

      it 'returns a Hash of validated data' do
        months = 10
        years = 3
        params = {
            embargoStatus: 'Embargoed',
            embargoDate: {
                start: {date: '', label: 'Today'},
                duration: {years: years, months: months},
                end: {date: '', label: ''}
            },
            embargoReason: ['Ethical conditions or agreements'],
            embargoRelease: 'Automatically lift the embargo'
        }

        result = Ora.validateEmbargoDates(params, 'uuid:nn999n999', nil)

        expect(result[:embargoStatus]).to eq('Embargoed')
        expect(result[:embargoDate]).to be_an(Array)
        expect(result[:embargoDate]).not_to be_empty
        embargo_date = result[:embargoDate].first
        start_date = Date.today
        end_date = start_date + years.years + months.months
        expect(embargo_date['id']).to eq('uuid:nn999n999#embargoDate')
        expect(embargo_date[:start]).to eq([{:date => start_date.strftime('%d %b %Y'), :label => 'Date', 'id' => 'uuid:nn999n999#embargoStart'}])
        expect(embargo_date[:duration]).to eq([{:years => "#{years}", :months => "#{months}", 'id' => 'uuid:nn999n999#embargoDuration' }])
        expect(embargo_date[:end]).to eq([{:date => end_date.strftime('%d %b %Y'), :label => 'Defined', 'id' => 'uuid:nn999n999#embargoEnd'}])
        expect(result[:embargoReason]).to eq(['Ethical conditions or agreements'])
        expect(result[:embargoRelease]).to eq('Automatically lift the embargo')
      end
    end

    context 'embargoed from  publication date for a given duration with year defined' do
      before(:each) do
        Timecop.freeze
      end

      after(:each) do
        Timecop.return
      end

      it 'returns a Hash of validated data' do
        years = 3
        params = {
            embargoStatus: 'Embargoed',
            embargoDate: {
                start: {date: '', label: 'Publication date'},
                duration: {years: years, months: ''},
                end: {date: '', label: ''}
            },
            embargoReason: ['Ethical conditions or agreements'],
            embargoRelease: 'Automatically lift the embargo'
        }

        result = Ora.validateEmbargoDates(params, 'uuid:nn999n999', nil)

        expect(result[:embargoStatus]).to eq('Embargoed')
        expect(result[:embargoDate]).to be_an(Array)
        expect(result[:embargoDate]).not_to be_empty
        embargo_date = result[:embargoDate].first
        start_date = Date.today
        end_date = start_date + years.years
        expect(embargo_date['id']).to eq('uuid:nn999n999#embargoDate')
        expect(embargo_date[:start]).to eq([{:date => start_date.strftime('%d %b %Y'), :label => 'Publication date', 'id' => 'uuid:nn999n999#embargoStart'}])
        expect(embargo_date[:duration]).to eq([{:years => "#{years}", :months => '0', 'id' => 'uuid:nn999n999#embargoDuration' }])
        expect(embargo_date[:end]).to eq([{:date => end_date.strftime('%d %b %Y'), :label => 'Approximate', 'id' => 'uuid:nn999n999#embargoEnd'}])
        expect(result[:embargoReason]).to eq(['Ethical conditions or agreements'])
        expect(result[:embargoRelease]).to eq('Automatically lift the embargo')
      end
    end

    context 'embargoed from given date for a given duration with month defined' do

      before(:each) do
        Timecop.freeze
      end

      after(:each) do
        Timecop.return
      end

      it 'returns a Hash of validated data' do
        months = 10
        params = {
            embargoStatus: 'Embargoed',
            embargoDate: {
                start: {date: '2014-1', label: '"'},
                duration: {years: '', months: months},
                end: {date: '', label: ''}
            },
            embargoReason: ['Ethical conditions or agreements'],
            embargoRelease: 'Automatically lift the embargo'
        }

        result = Ora.validateEmbargoDates(params, 'uuid:nn999n999', nil)

        expect(result[:embargoStatus]).to eq('Embargoed')
        expect(result[:embargoDate]).to be_an(Array)
        expect(result[:embargoDate]).not_to be_empty
        embargo_date = result[:embargoDate].first
        start_date = Date.today
        end_date = start_date + months.months
        expect(embargo_date['id']).to eq('uuid:nn999n999#embargoDate')
        expect(embargo_date[:start]).to eq([{:date => start_date.strftime('%d %b %Y'), :label => 'Date', 'id' => 'uuid:nn999n999#embargoStart'}])
        expect(embargo_date[:duration]).to eq([{:years => '0', :months => "#{months}", 'id' => 'uuid:nn999n999#embargoDuration' }])
        expect(embargo_date[:end]).to eq([{:date => end_date.strftime('%d %b %Y'), :label => 'Approximate', 'id' => 'uuid:nn999n999#embargoEnd'}])
        expect(result[:embargoReason]).to eq(['Ethical conditions or agreements'])
        expect(result[:embargoRelease]).to eq('Automatically lift the embargo')
      end
    end

  end
end