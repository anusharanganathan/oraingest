require 'rails_helper'

shared_examples_for 'build_metadata' do

  let(:model) { described_class.new }
  let(:user) { FactoryGirl.build(:user) }

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
    context 'with valid parameters' do
      it 'creates the language metadata' do
        if model.respond_to?(:language)
          params = {languageLabel: 'English', languageCode: 'eng', languageAuthority: '', languageScheme: ''}.with_indifferent_access

          model.buildLanguage(params)
          expect(model.language).to be_an(Array)
          expect(model.language).not_to be_empty
          expect(model.language.size).to eq(1)
          expect(model.language.first).to be_a(MadsLanguage)
        end
      end
    end
    context 'with invalid parameters' do
      context 'missing languageLabel' do
        it 'does not create a language' do
          if model.respond_to?(:language)
            params = {languageLabel: '', languageCode: '', languageAuthority: '', languageScheme: ''}.with_indifferent_access

            model.buildLanguage(params)
            expect(model.language).to be_an(Array)
            expect(model.language).to be_empty
          end
        end
      end
    end
  end

  describe '#buildSubject' do
    context 'with valid parameters' do
      it 'creates a single subject' do
        skip 'not working for DatasetAgreement'
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
          skip 'not working for DatasetAgreement'
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
          if model.respond_to?(:worktype)
            params = {typeLabel: 'Article'}.with_indifferent_access
            model.buildWorktype(params)
            expect(model.worktype).to be_an(Array)
            expect(model.worktype).not_to be_empty
            expect(model.worktype.size).to eq(1)
            expect(model.worktype.first).to be_a(WorkType)
            expect(model.worktype.first.typeLabel).to eq(['Article'])
          end
        end
      end

      context 'when typeLabel is Report' do
        it 'creates the worktype' do
          if model.respond_to?(:worktype)
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
    end

    context 'with invalid parameters' do
      it 'creates a worktype based on the model class' do
        if model.respond_to?(:worktype)
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
  end

  describe '#buildRightsActivity' do
    context 'license' do
      context 'with valid parameters' do
        it 'creates license' do
          if model.respond_to?(:rightsActivity)
            params = {
                'license' => {'licenseLabel' => 'Open Government Licence (OGL)', 'licenseStatement' => 'Licence statement'}
            }.with_indifferent_access

            model.buildRightsActivity(params)
            expect(model.license).to be_an(Array)
            expect(model.license).not_to be_empty
            expect(model.license.size).to eq(1)
            expect(model.license.first).to be_a(LicenseStatement)
          end
        end
      end
    end

    context 'rights' do
      context 'with valid parameters' do
        it 'creates rights activity'
      end
    end
  end

  describe '#buildAccessRights' do
    context 'with valid parameters' do
      it 'creates access rights' do
        params = {
                "embargoStatus" => "Embargoed",
                "embargoDate" => {
                    "end" => {
                        "label" => "",
                        "date" => ""
                    },
                    "duration" => {
                        "years" => "2",
                        "months" => "3"
                    },
                    "start" => {
                        "label" => "Today",
                        "date" => ""
                    }
                },
                "embargoRelease" => "Automatically lift the embargo",
                "embargoReason" => ["Conditional access only", "Copyright or other intellectual property restrictions"]
            }.with_indifferent_access

        model.buildAccessRights(params, nil)
        expect(model.accessRights).to be_an(Array)
        expect(model.accessRights).not_to be_empty
        expect(model.accessRights.size).to eq(1)
        expect(model.accessRights.first).to be_a(EmbargoInfo)
      end
    end
  end

  describe '#buildInternalRelations' do
    context 'with valid parameters' do
      it 'creates an internal relatopn' do
        params = {
            "0" => {
                "identifier" => "content01",
                "description" => "",

                "accessRights" => {
                    "embargoStatus" => "Embargoed",
                    "embargoDate" => {
                        "end" => {
                            "label" => "",
                            "date" => ""
                        },
                        "duration" => {
                            "years" => "2",
                            "months" => "3"
                        },
                        "start" => {
                            "label" => "Today",
                            "date" => ""
                        }
                    },
                    "embargoRelease" => "Automatically lift the embargo",
                    "embargoReason" => ["Conditional access only", "Copyright or other intellectual property restrictions"]
                }
            }
        }.with_indifferent_access

        contents = [{
                "name" => "test.docx",
                "size" => 3732,
                "url" => "/articles/uuid:21c7aba4-d854-4144-8e78-560861412cc1/file/content01",
                "thumbnail_url" => "fileIcons/docx-icon-48x48.png",
                "delete_url" => "/articles/uuid:21c7aba4-d854-4144-8e78-560861412cc1/file/content01",
                "delete_type" => "DELETE"
            }]

        model.buildInternalRelations(params, nil, contents)
        expect(model.hasPart).to be_an(Array)
        expect(model.hasPart).not_to be_empty
        expect(model.hasPart.size).to eq(1)
        expect(model.hasPart.first).to be_a(InternalRelations)
      end
    end
  end

  describe '#buildExternalRelations' do
    context 'with valid parameters' do
      it 'creates a qualified relation' do
        params = {
            '0' => {
                'entity_attributes' => {
                    '0' => {
                        'title' => 'Related title', 'description' => 'related abstract', 'identifier' => '', 'citation' => ''
                    }
                }, 
                'relation' => 'http://purl.org/dc/terms/isPartOf'
            }
        }.with_indifferent_access

        model.buildExternalRelations(params)
        expect(model.qualifiedRelation).to be_an(Array)
        expect(model.qualifiedRelation).not_to be_empty
        expect(model.qualifiedRelation.size).to eq(1)
        expect(model.qualifiedRelation.first).to be_a(ExternalRelationsQualified)
      end
    end
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
    context 'with valid parameters' do
      it 'creates a creation activity' do
        params = {
            'creator_attributes' => {
                '0' => {
                    'name' => 'Joe Smith', 'email' => 'jsmith@jsmith.com', 'sameAs' => '', 'role' => 'http://purl.org/dc/terms/contributor', 'affiliation' => {
                        'name' => '', 'sameAs' => ''
                    }
                }
            }
        }.with_indifferent_access

        model.buildCreationActivity(params)
        expect(model.creation).to be_an(Array)
        expect(model.creation).not_to be_empty
        expect(model.creation.size).to eq(1)
        expect(model.creation.first).to be_a(CreationActivity)
      end
    end
  end

  describe '#buildTitularActivity' do
    context 'with valid parameters' do
      it 'creates titular activity' do
        if model.respond_to?(:titularActivity)
          params = {
              'titular_attributes' => {
                  '0' => {'name' => 'Joe Steward', 'roleHeldBy' => '', 'role' => 'http://vocab.ox.ac.uk/ora#headOfFaculty', 'affiliation' => {
                      'name' => 'Affiliation', 'sameAs' => ''
                  }
                  }
              }
          }.with_indifferent_access
          
          model.buildTitularActivity(params)
          expect(model.titularActivity).to be_an(Array)
          expect(model.titularActivity).not_to be_empty
          expect(model.titularActivity.size).to eq(1)
          expect(model.titularActivity.first).to be_a(TitularActivity)
        end
      end
    end
  end

  describe '#buildPublicationActivity' do
    context 'with valid parameters' do
      it 'creates a publication activity' do
        if model.respond_to?(:publication)
          params = {
              'publisher_attributes' => {
                  '0' => {
                      'agent_attributes' => {
                          '0' => {
                              'name' => 'University of Oxford', 'id' => 'info:fedora/uuid:f342460d-8caf-446f-9015-55d7d56207bc#publisher'
                          }
                      },
                      'id' => 'info:fedora/uuid:f342460d-8caf-446f-9015-55d7d56207bc#publicationAssociation'
                  }
              },
              'datePublished' => '2015', 'hasDocument_attributes' => {
                  '0' => {
                      'doi' => '10.5072/bodleian:m326m821c'
                  }
              }
          }.with_indifferent_access

          model.buildPublicationActivity(params)
          expect(model.publication).to be_an(Array)
          expect(model.publication).not_to be_empty
          expect(model.publication.size).to eq(1)
          expect(model.publication.first).to be_a(PublicationActivity)
        end
      end
    end
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
    context ' with parameters' do
      let(:params) {
        {
            language: {},
            subject: {},
            worktype: {},
            temporal: {},
            dateCollected: {},
            spatial: {},
            storageAgreement: {},
            license: {},
            rights: {},
            publication: {},
            accessRights: {},
            hasPart: {},
            qualifiedRelation: {},
            funding: {},
            creation: {},
            titularActivity: {},
            valid: {},
            invoice: {}
        }.with_indifferent_access
      }

      it 'should build the metadata' do
        expect(model).to receive(:buildLanguage).with(params[:language])
        expect(model).to receive(:buildSubject).with(params[:subject])
        expect(model).to receive(:buildWorktype).with(params[:worktype])
        expect(model).to receive(:buildTemporalData).with(params[:temporal])
        expect(model).to receive(:buildDateCollected).with(params[:dateCollected])
        expect(model).to receive(:buildSpatialData).with(params[:spatial])
        expect(model).to receive(:buildStorageAgreementData).with(params[:storageAgreement])
        expect(model).to receive(:buildRightsActivity).with(params)
        expect(model).to receive(:buildPublicationActivity).with(params[:publication])
        expect(model).to receive(:buildAccessRights).with(params[:accessRights],nil)
        expect(model).to receive(:buildInternalRelations).with(params[:hasPart], nil, [])
        expect(model).to receive(:buildExternalRelations).with(params[:qualifiedRelation])
        expect(model).to receive(:buildFundingActivity).with(params[:funding])
        expect(model).to receive(:buildCreationActivity).with(params[:creation])
        expect(model).to receive(:buildTitularActivity).with(params[:titularActivity])
        expect(model).to receive(:buildValidityDate).with(params[:valid])
        expect(model).to receive(:buildInvoiceData).with(params[:invoice])

        model.buildMetadata(params, [], user)
      end
    end

    context 'without parameters' do
      let(:params) {
        {
        }.with_indifferent_access
      }

      it 'should build the metadata' do
        expect(model).not_to receive(:buildLanguage)
        expect(model).not_to receive(:buildSubject)
        expect(model).not_to receive(:buildWorktype)
        expect(model).not_to receive(:buildTemporalData)
        expect(model).not_to receive(:buildDateCollected)
        expect(model).not_to receive(:buildSpatialData)
        expect(model).not_to receive(:buildStorageAgreementData)
        expect(model).not_to receive(:buildRightsActivity)
        expect(model).not_to receive(:buildPublicationActivity)
        expect(model).not_to receive(:buildAccessRights)
        expect(model).not_to receive(:buildInternalRelations)
        expect(model).not_to receive(:buildExternalRelations)
        expect(model).not_to receive(:buildFundingActivity)
        expect(model).not_to receive(:buildCreationActivity)
        expect(model).not_to receive(:buildTitularActivity)
        expect(model).not_to receive(:buildValidityDate)
        expect(model).not_to receive(:buildInvoiceData)

        model.buildMetadata(params, [], user)
      end
    end
  end
end