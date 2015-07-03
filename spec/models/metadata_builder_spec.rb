require 'rails_helper'

describe MetadataBuilder do
  let(:user) { FactoryGirl.build(:user) }

  context 'common' do
    let(:model) { Article.new }
    let(:builder) { MetadataBuilder.new(model) }

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
              invoice: {},
          }.with_indifferent_access
        }

        it 'should build the metadata' do
          expect(builder).to receive(:buildLanguage).with(params[:language])
          expect(builder).to receive(:buildSubject).with(params[:subject])
          expect(builder).to receive(:buildWorktype).with(params[:worktype])
          expect(builder).to receive(:buildTemporalData).with(params[:temporal])
          expect(builder).to receive(:buildDateCollected).with(params[:dateCollected])
          expect(builder).to receive(:buildSpatialData).with(params[:spatial])
          expect(builder).to receive(:buildStorageAgreementData).with(params[:storageAgreement])
          expect(builder).to receive(:buildRightsActivity).with(params)
          expect(builder).to receive(:buildPublicationActivity).with(params[:publication])
          expect(builder).to receive(:buildAccessRights).with(params[:accessRights],nil)
          expect(builder).to receive(:buildInternalRelations).with(params[:hasPart], nil, [])
          expect(builder).to receive(:buildExternalRelations).with(params[:qualifiedRelation])
          expect(builder).to receive(:buildFundingActivity).with(params[:funding])
          expect(builder).to receive(:buildCreationActivity).with(params[:creation])
          expect(builder).to receive(:buildTitularActivity).with(params[:titularActivity])
          expect(builder).to receive(:buildValidityDate).with(params[:valid])
          expect(builder).to receive(:buildInvoiceData).with(params[:invoice])

          builder.build(params, [], user)
        end
      end

      context 'without parameters' do
        let(:params) {
          {
          }.with_indifferent_access
        }

        it 'should build the metadata' do
          expect(builder).not_to receive(:buildLanguage)
          expect(builder).not_to receive(:buildSubject)
          expect(builder).not_to receive(:buildWorktype)
          expect(builder).not_to receive(:buildTemporalData)
          expect(builder).not_to receive(:buildDateCollected)
          expect(builder).not_to receive(:buildSpatialData)
          expect(builder).not_to receive(:buildStorageAgreementData)
          expect(builder).not_to receive(:buildRightsActivity)
          expect(builder).not_to receive(:buildPublicationActivity)
          expect(builder).not_to receive(:buildAccessRights)
          expect(builder).not_to receive(:buildInternalRelations)
          expect(builder).not_to receive(:buildExternalRelations)
          expect(builder).not_to receive(:buildFundingActivity)
          expect(builder).not_to receive(:buildCreationActivity)
          expect(builder).not_to receive(:buildTitularActivity)
          expect(builder).not_to receive(:buildValidityDate)
          expect(builder).not_to receive(:buildInvoiceData)

          builder.build(params, [], user)
        end
      end
    end

    describe '#normalizeParams' do
      context 'when argument is a Hash' do
        it 'returns an array' do
          params = {key2: 'value1', key2: 'value2'}
          result = builder.send(:normalizeParams, params)
          expect(result).to be_an(Array)
          expect(result).to eq(params.values)
        end
      end

      context 'when argument is an Array' do
        it 'returns an array' do
          params = ['value1', 'value2']
          result = builder.send(:normalizeParams, params)
          expect(result).to be_an(Array)
          expect(result).to eq(params)
        end
      end
    end

    describe '#validatePermissions' do
      context 'when parameters include name and access' do
        it 'returns an array' do
          params = {'0' => {'type' => 'user', 'name' => 'name', 'access' => 'read'}}.with_indifferent_access
          result = builder.send(:validatePermissions, params)
          expect(result).to be_an(Array)
          expect(result).not_to be_empty
        end
      end

      context 'when parameters include name and do not include access' do
        it 'returns an empty array' do
          params = {'0' => {'type' => 'user', 'name' => 'name'}}.with_indifferent_access
          result = builder.send(:validatePermissions, params)
          expect(result).to be_an(Array)
          expect(result).to be_empty
        end
      end

      context 'when parameters include access and do not include name' do
        it 'returns an empty array' do
          params = {'0' => {'type' => 'user', 'access' => 'read'}}.with_indifferent_access
          result = builder.send(:validatePermissions, params)
          expect(result).to be_an(Array)
          expect(result).to be_empty
        end
      end

      context 'when parameters do not include name or access' do
        it 'returns an empty array' do
          params = {'0' => {'type' => 'user'}}.with_indifferent_access
          result = builder.send(:validatePermissions, params)
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
          params = {languageLabel: 'English', languageCode: 'eng', languageAuthority: '', languageScheme: ''}.with_indifferent_access

          builder.send(:buildLanguage, params)
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

            builder.send(:buildLanguage, params)
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
          builder.send(:buildSubject, params)
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
            builder.send(:buildSubject, params)
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
            builder.send(:buildWorktype, params)
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
            builder.send(:buildWorktype, params)
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
          builder.send(:buildWorktype, params)
          expect(model.worktype).to be_an(Array)
          expect(model.worktype).not_to be_empty
          expect(model.worktype.size).to eq(1)
          expect(model.worktype.first).to be_a(WorkType)
          expect(model.worktype.first.typeLabel).to eq([model.class.to_s])
        end
      end
    end

    describe '#buildRightsActivity' do
      context 'license and rights' do
        context 'with valid parameters' do
          it 'creates license and rights' do
            params = {
                'license' => {'licenseLabel' => 'Open Government Licence (OGL)', 'licenseStatement' => 'Licence statement'},
                'creator_attributes' => {
                  '0' => {
                      'name' => 'Joe Smith',
                      'email' => 'jsmith@jsmith.com',
                      'sameAs' => '',
                      'role' => ['http://purl.org/dc/terms/contributor',  'http://vocab.ox.ac.uk/ora#copyrightHolder', '', nil, 'http://purl.org/dc/terms/creator'],
                      'affiliation' => {
                          'name' => '', 'sameAs' => ''
                      }
                  }
                },
                #'dateCopyrighted' => '2015',
                'rightsHolder' => ['Joe Bloggs'],
                'rights'=>{'rightsStatement'=>'A rights statement from the publisher'}
            }.with_indifferent_access
            builder.send(:buildCreationActivity, params['creator_attributes'])
            builder.send(:buildRightsActivity, params)
            expect(model.license).to be_an(Array)
            expect(model.license).not_to be_empty
            expect(model.license.size).to eq(1)
            expect(model.license.first).to be_a(LicenseStatement)
            #TODO: Fix the following to
            #expect(model.dateCopyrighted).not_to be_empty
            #expect(model.dateCopyrighted).to eq("2015")
            #expect(model.rightsHolder).to be_an(Array)
            #expect(model.rightsHolder.size).to eq(2)
            expect(model.rights).not_to be_empty
            expect(model.rights.size).to eq(1)
            expect(model.rights.first).to be_a(RightsStatement)
            expect(model.rights.first.rightsType.first).to eq('http://purl.org/dc/terms/RightsStatement')
            expect(model.rights.first.rightsStatement.first).to eq('A rights statement from the publisher')
          end
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

          builder.send(:buildAccessRights, params, nil)
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

          builder.send(:buildInternalRelations, params, nil, contents)
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

          builder.send(:buildExternalRelations, params)
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

          builder.send(:buildFundingActivity, params)
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
                      'name' => 'Joe Smith',
                      'email' => 'jsmith@jsmith.com',
                      'sameAs' => '',
                      'role' => ['http://purl.org/dc/terms/contributor',  'http://vocab.ox.ac.uk/ora#copyrightHolder', nil, 'http://purl.org/dc/terms/creator'],
                      'affiliation' => {
                          'name' => '', 'sameAs' => ''
                      }
                  }
              }
          }.with_indifferent_access
          #TODO: role with value '' is not rejected

          builder.send(:buildCreationActivity, params)
          expect(model.creation).to be_an(Array)
          expect(model.creation).not_to be_empty
          expect(model.creation.size).to eq(1)
          expect(model.creation.first).to be_a(CreationActivity)
          expect(model.creation.first.creator.first.role).to be_an(Array)
          expect(model.creation.first.creator.first.role.size).to eq(3)
        end
      end
    end

    describe '#buildPublicationActivity' do
      context 'with valid parameters' do
        it 'creates a publication activity' do
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

          builder.send(:buildPublicationActivity, params)
          expect(model.publication).to be_an(Array)
          expect(model.publication).not_to be_empty
          expect(model.publication.size).to eq(1)
          expect(model.publication.first).to be_a(PublicationActivity)
        end
      end
    end

    describe '#buildStorageAgreementData' do
      pending 'implement this'
    end

    describe '#buildValidityDate' do
      pending 'implement this'
    end

    describe '#buildInvoiceData' do
      pending 'implement this'
    end

  end

  context 'DatasetAgreement' do
    let(:model) { DatasetAgreement.new }
    let(:builder) { MetadataBuilder.new(model) }

    describe '#buildTitularActivity' do
      context 'with valid parameters' do
        it 'creates titular activity' do
          params = {
              'titular_attributes' => {
                  '0' => {'name' => 'Joe Steward', 'roleHeldBy' => '', 'role' => ['http://vocab.ox.ac.uk/ora#headOfFaculty'], 'affiliation' => {
                      'name' => 'Affiliation', 'sameAs' => ''
                  }
                  }
              }
          }.with_indifferent_access

          builder.send(:buildTitularActivity, params)
          expect(model.titularActivity).to be_an(Array)
          expect(model.titularActivity).not_to be_empty
          expect(model.titularActivity.size).to eq(1)
          expect(model.titularActivity.first).to be_a(TitularActivity)
        end
      end
    end
  end

  context 'Dataset' do
    let(:model) { Dataset.new }
    let(:builder) { MetadataBuilder.new(model) }

    describe '#buildTemporalData' do
      context 'with both start and end parameters' do
        it 'creates temporal' do
          params = {'start' => '1979', 'end' => '1990'}.with_indifferent_access
          builder.send(:buildTemporalData, params)
          expect(model.temporal).to be_an(Array)
          expect(model.temporal).not_to be_empty
          expect(model.temporal.size).to eq(1)
          expect(model.temporal.first).to be_a(DateDuration)
        end
      end
      context 'with only start parameter' do
        it 'creates temporal' do
          params = {'start' => '1979', 'end' => ''}.with_indifferent_access
          builder.send(:buildTemporalData, params)
          expect(model.temporal).to be_an(Array)
          expect(model.temporal).not_to be_empty
          expect(model.temporal.size).to eq(1)
          expect(model.temporal.first).to be_a(DateDuration)
        end
      end

      context 'with only end parameter' do
        it 'creates temporal' do
          params = {'start' => '', 'end' => '1990'}.with_indifferent_access
          builder.send(:buildTemporalData, params)
          expect(model.temporal).to be_an(Array)
          expect(model.temporal).not_to be_empty
          expect(model.temporal.size).to eq(1)
          expect(model.temporal.first).to be_a(DateDuration)
        end
      end

      context 'with invalid parameters' do
        context 'start and end missing' do
          it 'does not create temporal' do
            params = {'start' => '', 'end' => ''}.with_indifferent_access
            builder.send(:buildTemporalData, params)
            expect(model.temporal).to be_an(Array)
            expect(model.temporal).to be_empty
          end
        end
      end
    end

    describe '#buildDateCollected' do
      context 'with both start and end parameters' do
        it 'creates date collected' do
          params = {'start' => '01/05/2015', 'end' => '03/05/2015'}.with_indifferent_access
          builder.send(:buildDateCollected, params)
          expect(model.dateCollected).to be_an(Array)
          expect(model.dateCollected).not_to be_empty
          expect(model.dateCollected.size).to eq(1)
          expect(model.dateCollected.first).to be_a(DateDuration)
        end
      end

      context 'with only start parameter' do
        it 'creates date collected' do
          params = {'start' => '01/05/2015', 'end' => ''}.with_indifferent_access
          builder.send(:buildDateCollected, params)
          expect(model.dateCollected).to be_an(Array)
          expect(model.dateCollected).not_to be_empty
          expect(model.dateCollected.size).to eq(1)
          expect(model.dateCollected.first).to be_a(DateDuration)
        end
      end

      context 'with only end parameter' do
        it 'creates date collected' do
          params = {'start' => '', 'end' => '03/05/2015'}.with_indifferent_access
          builder.send(:buildDateCollected, params)
          expect(model.dateCollected).to be_an(Array)
          expect(model.dateCollected).not_to be_empty
          expect(model.dateCollected.size).to eq(1)
          expect(model.dateCollected.first).to be_a(DateDuration)
        end
      end

      context 'with invalid parameters' do
        context 'start and end missing' do
          it 'does not create date collected' do
            params = {'start' => '', 'end' => ''}.with_indifferent_access
            builder.send(:buildDateCollected, params)
            expect(model.dateCollected).to be_an(Array)
            expect(model.dateCollected).to be_empty
          end
        end
      end
    end

    describe '#buildSpatialData' do
      context 'with valid parameters' do
        it 'creates spatial' do
          params = {'value' => 'UK'}.with_indifferent_access
          builder.send(:buildSpatialData, params)
          expect(model.spatial).to be_an(Array)
          expect(model.spatial).not_to be_empty
          expect(model.spatial.size).to eq(1)
          expect(model.spatial.first).to be_a(Location)
        end
      end
      context 'with invalid parameters' do
        it 'does not create spatial' do
          params = {'value' => ''}.with_indifferent_access
          builder.send(:buildSpatialData, params)
          expect(model.spatial).to be_an(Array)
          expect(model.spatial).to be_empty
        end
      end

    end
  end

  describe 'embargo_date' do
    let(:model) { Article.new }
    let(:builder) { MetadataBuilder.new(model) }

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

        result = builder.send(:validateEmbargoDates, params, 'uuid:nn999n999', nil)

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

        result = builder.send(:validateEmbargoDates, params, 'uuid:nn999n999', nil)

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

          result = builder.send(:validateEmbargoDates, params, 'uuid:nn999n999', nil)

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

          result = builder.send(:validateEmbargoDates, params, 'uuid:nn999n999', nil)

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

          result = builder.send(:validateEmbargoDates, params, 'uuid:nn999n999', nil)

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

          result = builder.send(:validateEmbargoDates, params, 'uuid:nn999n999', nil)

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

end
