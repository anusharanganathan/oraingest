require 'rails_helper'

shared_examples_for 'build_metadata' do

  let(:model) { described_class.new }

  describe '#normalizeParams' do
    context 'when argument is a Hash' do
      it 'returns an array' do
        params = {key2: 'value1', key2: 'value2'}
        result = model.normalizeParams(params)
        expect(result).to be_an(Array)
        expect(result).to eq(params.values)
      end
    end

    context 'when argument is an Array' do
      it 'returns an array' do
        params = ['value1', 'value2']
        result = model.normalizeParams(params)
        expect(result).to be_an(Array)
        expect(result).to eq(params)
      end
    end
  end

  describe '#validatePermissions' do
    context 'when parameters include name and access' do
      it 'returns an array' do
        params = {'0' => {'type' => 'user', 'name' => 'name', 'access' => 'read'}}.with_indifferent_access
        result = model.validatePermissions(params)
        expect(result).to be_an(Array)
        expect(result).not_to be_empty
      end
    end

    context 'when parameters include name and do not include access' do
      it 'returns an empty array' do
        params = {'0' => {'type' => 'user', 'name' => 'name'}}.with_indifferent_access
        result = model.validatePermissions(params)
        expect(result).to be_an(Array)
        expect(result).to be_empty
      end
    end

    context 'when parameters include access and do not include name' do
      it 'returns an empty array' do
        params = {'0' => {'type' => 'user', 'access' => 'read'}}.with_indifferent_access
        result = model.validatePermissions(params)
        expect(result).to be_an(Array)
        expect(result).to be_empty
      end
    end

    context 'when parameters do not include name or access' do
      it 'returns an empty array' do
        params = {'0' => {'type' => 'user'}}.with_indifferent_access
        result = model.validatePermissions(params)
        expect(result).to be_an(Array)
        expect(result).to be_empty
      end
    end
  end

  describe '#validatePermissionsToRevoke' do
    pending 'implement this'
  end

  describe '#validateWorkflow' do
    pending 'implement this'
  end

  describe '#buildLanguage' do
    pending 'implement this'
    context 'with valid parameters' do
      it 'creates the language metadata' do
        params = {languageLabel: 'English', languageCode: 'eng', languageAuthority: '', languageScheme: ''}.with_indifferent_access
        model.buildLanguage(params)
        expect(model.language).to be_an(Array)
        expect(model.language).not_to be_empty
        expect(model.language.size).to eq(1)
        expect(model.language.first).to be_a(MadsLanguage)
      end
    end
    context 'with invalid parameters' do
      context 'missing languageLabel' do
        it 'does not create a language' do
          params = {languageLabel: '', languageCode: '', languageAuthority: '', languageScheme: ''}.with_indifferent_access
          model.buildLanguage(params)
          expect(model.language).to be_an(Array)
          expect(model.language).to be_empty
        end
      end
    end
  end

  describe '#buildSubject' do
    context 'with valid parameters' do
      it 'creates a single subject' do
        params = {'0' => {subjectLabel: 'Subject #1', subjectAuthority: 'Authority', subjectScheme: 'scheme'}}.with_indifferent_access
        model.buildSubject(params)
        expect(model.subject).to be_an(Array)
        expect(model.subject).not_to be_empty
        expect(model.subject.size).to eq(1)
        expect(model.subject.first).to be_a(MadsSubject)
      end
    end

    context 'with invalid parameters' do
      context 'missing subjectLabel' do
        it 'does not create a subject' do
          params = {'0' => {subjectLabel: '', subjectAuthority: 'Authority', subjectScheme: 'scheme'}}.with_indifferent_access
          model.buildSubject(params)
          expect(model.subject).to be_an(Array)
          expect(model.subject).to be_empty
        end
      end
    end
  end

  describe '#buildWorktype' do
    context 'with valid parameters' do
      context 'when typeLabel is Article' do
        it 'creates the worktype' do
          params = {typeLabel: 'Article'}.with_indifferent_access
          model.buildWorktype(params)
          expect(model.worktype).to be_an(Array)
          expect(model.worktype).not_to be_empty
          expect(model.worktype.size).to eq(1)
          expect(model.worktype.first).to be_a(WorkType)
          expect(model.worktype.first.typeLabel).to eq(['Article'])
        end
      end

      context 'when typeLabel is Report' do
        it 'creates the worktype' do
          params = {typeLabel: 'Report'}.with_indifferent_access
          model.buildWorktype(params)
          expect(model.worktype).to be_an(Array)
          expect(model.worktype).not_to be_empty
          expect(model.worktype.size).to eq(1)
          expect(model.worktype.first).to be_a(WorkType)
          expect(model.worktype.first.typeLabel).to eq(['Report'])
        end
      end
    end

    context 'with invalid parameters' do
      it 'creates a worktype based on the model class' do
        params = {typeLabel: ''}.with_indifferent_access
        model.buildWorktype(params)
        expect(model.worktype).to be_an(Array)
        expect(model.worktype).not_to be_empty
        expect(model.worktype.size).to eq(1)
        expect(model.worktype.first).to be_a(WorkType)
        expect(model.worktype.first.typeLabel).to eq([model.class.to_s])
      end
    end
  end

  describe '#buildRightsActivity' do
    pending 'implement this'
  end

  describe '#buildAccessRights' do
    pending 'implement this'
  end

  describe '#buildInternalRelations' do
    pending 'implement this'
  end

  describe '#buildExternalRelations' do
    pending 'implement this'
  end

  describe '#buildFundingActivity' do
    context 'with valid parameters' do
      it 'creates a funding activity' do
        params = {
            'hasFundingAward' => 'yes',
            'funder_attributes' => {
                '0' => {'agent_attributes' => {'0'=>{'name' => 'Funder name'}},
                        'awards_attributes' => {'0' => {'grantNumber' => 'Grant number 1'}},
                        'funds' => 'info:fedora/uuid:f342460d-8caf-446f-9015-55d7d56207bc#creator1'}
            }
        }.with_indifferent_access

        model.buildFundingActivity(params)
        expect(model.funding).to be_an(Array)
        expect(model.funding).not_to be_empty
        expect(model.funding.size).to eq(1)
        expect(model.funding.first).to be_a(FundingActivity)
      end
    end
  end

  describe '#buildCreationActivity' do
    pending 'implement this'
  end

  describe '#buildTitularActivity' do
    pending 'implement this'
  end

  describe '#buildPublicationActivity' do
    pending 'implement this'
  end

  describe '#buildTemporalData' do
    context 'with both start and end parameters' do
      it 'creates temporal' do
        if model.respond_to?(:temporal)
          params = {'start' => '1979', 'end' => '1990'}.with_indifferent_access
          model.buildTemporalData(params)
          expect(model.temporal).to be_an(Array)
          expect(model.temporal).not_to be_empty
          expect(model.temporal.size).to eq(1)
          expect(model.temporal.first).to be_a(DateDuration)
        end
      end
    end
    context 'with only start parameter' do
      it 'creates temporal' do
        if model.respond_to?(:temporal)
          params = {'start' => '1979', 'end' => ''}.with_indifferent_access
          model.buildTemporalData(params)
          expect(model.temporal).to be_an(Array)
          expect(model.temporal).not_to be_empty
          expect(model.temporal.size).to eq(1)
          expect(model.temporal.first).to be_a(DateDuration)
        end
      end
    end

    context 'with only end parameter' do
      it 'creates temporal' do
        if model.respond_to?(:temporal)
          params = {'start' => '', 'end' => '1990'}.with_indifferent_access
          model.buildTemporalData(params)
          expect(model.temporal).to be_an(Array)
          expect(model.temporal).not_to be_empty
          expect(model.temporal.size).to eq(1)
          expect(model.temporal.first).to be_a(DateDuration)
        end
      end
    end

    context 'with invalid parameters' do
      context 'start and end missing' do
        it 'does not create temporal' do
          if model.respond_to?(:temporal)
            params = {'start' => '', 'end' => ''}.with_indifferent_access
            model.buildTemporalData(params)
            expect(model.temporal).to be_an(Array)
            expect(model.temporal).to be_empty
          end
        end
      end
    end
  end

  describe '#buildDateCollected' do
    context 'with both start and end parameters' do
      it 'creates date collected' do
        if model.respond_to?(:dateCollected)
          params = {'start' => '01/05/2015', 'end' => '03/05/2015'}.with_indifferent_access
          model.buildDateCollected(params)
          expect(model.dateCollected).to be_an(Array)
          expect(model.dateCollected).not_to be_empty
          expect(model.dateCollected.size).to eq(1)
          expect(model.dateCollected.first).to be_a(DateDuration)
        end
      end
    end

    context 'with only start parameter' do
      it 'creates date collected' do
        if model.respond_to?(:dateCollected)
          params = {'start' => '01/05/2015', 'end' => ''}.with_indifferent_access
          model.buildDateCollected(params)
          expect(model.dateCollected).to be_an(Array)
          expect(model.dateCollected).not_to be_empty
          expect(model.dateCollected.size).to eq(1)
          expect(model.dateCollected.first).to be_a(DateDuration)
        end
      end
    end

    context 'with only end parameter' do
      it 'creates date collected' do
        if model.respond_to?(:dateCollected)
          params = {'start' => '', 'end' => '03/05/2015'}.with_indifferent_access
          model.buildDateCollected(params)
          expect(model.dateCollected).to be_an(Array)
          expect(model.dateCollected).not_to be_empty
          expect(model.dateCollected.size).to eq(1)
          expect(model.dateCollected.first).to be_a(DateDuration)
        end
      end
    end

    context 'with invalid parameters' do
      context 'start and end missing' do
        it 'does not create date collected' do
          if model.respond_to?(:dateCollected)
            params = {'start' => '', 'end' => ''}.with_indifferent_access
            model.buildDateCollected(params)
            expect(model.dateCollected).to be_an(Array)
            expect(model.dateCollected).to be_empty
          end
        end
      end
    end
  end

  describe '#buildSpatialData' do
    context 'with valid parameters' do
      it 'creates spatial' do
        if model.respond_to?(:spatial)
          params = {'value' => 'UK'}.with_indifferent_access
          model.buildSpatialData(params)
          expect(model.spatial).to be_an(Array)
          expect(model.spatial).not_to be_empty
          expect(model.spatial.size).to eq(1)
          expect(model.spatial.first).to be_a(Location)
        end
      end
    end
    context 'with invalid parameters' do
      it 'does not create spatial' do
        if model.respond_to?(:spatial)
          params = {'value' => ''}.with_indifferent_access
          model.buildSpatialData(params)
          expect(model.spatial).to be_an(Array)
          expect(model.spatial).to be_empty
        end
      end
    end

  end

  describe '#buildValidityDate' do
    pending 'implement this'
  end

  describe '#buildInvoiceData' do
    pending 'implement this'
  end

  describe '#buildMetadata' do
    pending 'implement this'
  end
end