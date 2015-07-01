# Returns an array containing the vhost 'CoSign service' value and URL
require 'vocabulary/camelot'
require 'vocabulary/ora'
require 'vocabulary/bibo'
require 'vocabulary/pso'
require 'vocabulary/fabio'

Sufia.config do |config|

  config.work_types = {
    'Article' => 'Article',
    'Book' => 'Book',
    'Conference Proceeding' => 'Conference Proceeding',
    'Data' => 'Data',
    'Thesis' => 'Thesis',
    'Part of Book' => 'Part of Book'
  }

  config.subtypes = {
    'article' => {
      'Article' => 'Article',
      'Discussion paper' => 'Discussion paper',
      'Journal article' => 'Journal article',
      'Newsletter' => 'Newsletter',
      'Policy briefing' => 'Policy briefing',
      'Press article' => 'Press article',
      'Pamphlet' => 'Pamphlet',
      'Patent' => 'Patent',
      'Report' => 'Report',
      'Research Paper' => 'Research Paper',
      'Review' => 'Review',
      'Technical report' => 'Technical report',
      'Working paper' => 'Working paper',
      'Other' => 'Other'
    },
    'book' => {
      'Book'=>'Book',
      'Book chapter' => 'Book chapter',
      'Book review' => 'Book review',
      'Book section' => 'Book section',
      'Edited book' => 'Edited book',
      'Edited volume' => 'Edited volume',
      'Monograph' => 'Monograph'
    },
    "dataset" => {
      "Dataset"=>"Dataset"
    },
    'thesis' => {
        'Thesis' => 'Thesis'
    }
  }

  config.type_authorities = {
    'article' => {
      'Article' => RDF::CAMELOT::article,
      'Discussion paper' => RDF::CAMELOT::discussionPaper,
      'Journal article' => RDF::CAMELOT::journalArticle,
      'Newsletter' => RDF::CAMELOT::newsletter,
      'Policy briefing' => RDF::CAMELOT::policyBriefing,
      'Press article' => RDF::CAMELOT::pressArticle,
      'Pamphlet' => RDF::CAMELOT::pamphlet,
      'Patent' => RDF::CAMELOT::patent,
      'Report' => RDF::CAMELOT::report,
      'Research Paper' => RDF::CAMELOT::researchPaper,
      'Review' => RDF::CAMELOT::review,
      'Technical report' => RDF::CAMELOT::technicalReport,
      'Working paper' => RDF::CAMELOT::workingPaper,
      'Other' => RDF::CAMELOT::article
    },
    "dataset" => {
      "Dataset" => RDF::CAMELOT::dataset,
    },
    'thesis' => {
        'Thesis' => RDF::CAMELOT::thesis
    }
  }

  config.publication_status = {
    'Accepted' => 'Accepted',
    'In Press' => 'In Press',
    'Not published' => 'Not published',
    'Published' => 'Published',
    'Submitted' => 'Submitted'
  }

  config.review_status = {
    'Peer reviewed' => 'Peer reviewed',
    'Reviewed' => 'Reviewed',
    'Under review' => 'Under review',
    'Not peer reviewed' => 'Not peer reviewed'
  }

  config.licenses = {
    'article' => {
      'CC Attribution (CC BY 2.5)' => 'CC Attribution (CC BY 2.5)',
      'CC Attribution-NoDerivs (CC BY-ND 2.5)' => 'CC Attribution-NoDerivs (CC BY-ND 2.5)',
      'CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)' => 'CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)',
      'CC Attribution-NonCommercial (CC BY-NC 2.5)' => 'CC Attribution-NonCommercial (CC BY-NC 2.5)',
      'CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)' => 'CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)',
      'CC Attribution-ShareAlike (CC BY-SA 2.5)' => 'CC Attribution-ShareAlike (CC BY-SA 2.5)',
      'GPL v2' => 'GPL v2',
      'LGPL v2.1' => 'LGPL v2.1',
      'MIT licence' => 'MIT licence',
      'Bespoke licence' => 'Bespoke licence'
    },
    "dataset" => {
      "ODC Attribution for data/databases (ODC-By)" => "ODC Attribution for data/databases (ODC-By)",
      "ODC Attribution Share-Alike for data/databases (ODC-ODbL)" => "ODC Attribution Share-Alike for data/databases (ODC-ODbL)",
      "ODC Public Domain for data/databases (PDDL)" => "ODC Public Domain for data/databases (PDDL)",
      "Open Government Licence (OGL)" => "Open Government Licence (OGL)",
      "OGL non commercial" => "OGL non commercial",
      "CC0 (CC Zero)" => "CC0 (CC Zero)",
      "Bespoke licence" => "Bespoke licence"
    },
    "thesis" => {
      "CC Attribution (CC BY 2.5)" => "CC Attribution (CC BY 2.5)",
      "CC Attribution-NoDerivs (CC BY-ND 2.5)" => "CC Attribution-NoDerivs (CC BY-ND 2.5)",
      "CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)" => "CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)",
      "CC Attribution-NonCommercial (CC BY-NC 2.5)" => "CC Attribution-NonCommercial (CC BY-NC 2.5)",
      "CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)" => "CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)",
      "CC Attribution-ShareAlike (CC BY-SA 2.5)" => "CC Attribution-ShareAlike (CC BY-SA 2.5)",
      "GPL v2" => "GPL v2",
      "LGPL v2.1" => "LGPL v2.1",
      "MIT licence" => "MIT licence",
      "Bespoke licence" => "Bespoke licence"
    },
  }

  config.license_urls = {
    'CC Attribution (CC BY 2.5)' => 'http://creativecommons.org/licenses/by/2.5/',
    'CC Attribution-NoDerivs (CC BY-ND 2.5)' => 'http://creativecommons.org/licenses/by-nd/2.5/',
    'CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)' => 'http://creativecommons.org/licenses/by-nc-nd/2.5/',
    'CC Attribution-NonCommercial (CC BY-NC 2.5)' => 'http://creativecommons.org/licenses/by-nc/2.5/',
    'CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)' => 'http://creativecommons.org/licenses/by-nc-sa/2.5/',
    'CC Attribution-ShareAlike (CC BY-SA 2.5)' => 'http://creativecommons.org/licenses/by-sa/2.5/',
    'GPL v2' => 'http://www.gnu.org/licenses/gpl.txt',
    'LGPL v2.1' => 'http://www.gnu.org/licenses/lgpl.txt',
    'MIT licence' => 'http://www.opensource.org/licenses/mit-license.php',
    'ODC Attribution for data/databases (ODC-By)' => 'http://opendatacommons.org/licenses/by/',
    'ODC Attribution Share-Alike for data/databases (ODC-ODbL)' => 'http://opendatacommons.org/licenses/odbl/',
    'ODC Public Domain for data/databases (PDDL)' => 'http://opendatacommons.org/licenses/pddl/',
    'Open Government Licence (OGL)' => ' http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/',
    'OGL non commercial' => 'http://www.nationalarchives.gov.uk/doc/non-commercial-government-licence/',
    'CC0 (CC Zero)' => 'http://creativecommons.org/choose/zero/'
  }

  config.attachment_types = {
    'article' => {
      'Content' => 'Content',
      'License agreement' => 'License agreement',
      'Rights agreement with publisher' => 'Rights agreement with publisher',
      'Personal correspondence to serve as agreement' => 'Personal correspondence to serve as agreement',
      "Publisher's APC or article charge request form" => "Publisher's APC or article charge request form"
    },
    "thesis" => {
      "Content" => "Content",
      "License agreement" => "License agreement",
      "Rights agreement with publisher" => "Rights agreement with publisher",
      "Copyright clearance letter" => "Copyright clearance letter"
    }
  }

  config.relationship_types = {
    'is a part of' => RDF::DC::isPartOf,
    'has a constituent part in' => RDF::DC::hasPart,
    'is a format of' => RDF::DC::isFormatOf, 
    'is referenced by' => RDF::DC::isReferencedBy,
    'references' => RDF::DC::references,
    'is replaced by' => RDF::DC::isReplacedBy,
    'replaces' => RDF::DC::replaces,
    'is required by' => RDF::DC::isRequiredBy,
    'requires' => RDF::DC::requires,
    'is a version of' => RDF::DC::isVersionOf
  }

  config.relationship_types_reverse = Hash[config.relationship_types.map{|k,v| [v.to_s, k]}]

  config.embargo_release_methods = {
    'Automatically lift the embargo' => 'Automatically lift the embargo',
    'Consult me before lifting embargo' => 'Consult me before lifting embargo'
  }

  config.embargo_options = [
    'Open access',
    'Access restricted until embargo end date',
    'Closed access',
  ]

  config.embargo_reasons = {
    "article" => {
      "Commercial confidentiality" => "Commercial confidentiality",
      "Publication pending" => "Publication pending",
      "Conditional access only" => "Conditional access only",
      "Copyright or other intellectual property restrictions"  => "Copyright or other intellectual property restrictions",
      "Ethical conditions or agreements"  => "Ethical conditions or agreements",
      "Legal conditions or agreements"  => "Legal conditions or agreements",
      "National security issues"  => "National security issues",
      "Patent pending"  => "Patent pending"
    },
    "dataset" => {
      "Commercial confidentiality" => "Commercial confidentiality",
      "Publication pending" => "Publication pending", 
      "Conditional access only" => "Conditional access only",
      "Copyright or other intellectual property restrictions"  => "Copyright or other intellectual property restrictions",
      "Ethical conditions or agreements"  => "Ethical conditions or agreements",
      "Legal conditions or agreements"  => "Legal conditions or agreements",
      "National security issues"  => "National security issues",
      "Patent pending"  => "Patent pending"
    },
    "thesis" => {
      "Commercial confidentiality" => "Commercial confidentiality",
      "Publication pending" => "Publication pending",
      "Conditional access only" => "Conditional access only",
      "Copyright or other intellectual property restrictions"  => "Copyright or other intellectual property restrictions",
      "Ethical conditions or agreements"  => "Ethical conditions or agreements",
      "Legal conditions or agreements"  => "Legal conditions or agreements",
      "National security issues"  => "National security issues",
      "Patent pending"  => "Patent pending"
    },
  }

  config.role_types = {
    'article' => {
      'Author' => RDF::ORA.author,
      'Editor' => RDF::BIBO.editor,
      'Contributor' => RDF::DC.contributor,
      'Copyright holder' => RDF::ORA.copyrightHolder,
    },
    'thesis' => {
      'Author' => RDF::ORA.author,
      'Supervisor' => RDF::ORA.supervisor,
      'Examiner' => RDF::ORA.examiner,
      'Contributor' => RDF::DC.contributor,
      'Copyright holder' => RDF::ORA.copyrightHolder,
    },
    'dataset' => {
      'Adapter' => RDF::ORA.adapter,
      'Contributor' => RDF::DC.contributor,
      'Copyright holder' => RDF::ORA.copyrightHolder,
      'Creator' => RDF::DC.creator,
      'Depositor' => RDF::ORA.depositor,
      'Editor' => RDF::ORA.editor,
      'Examiner' => RDF::ORA.examiner,
      'Funder' => RDF::ORA.funder,
      'Performer' => RDF::ORA.performer,
      'Principal Investigator' => RDF::ORA.principalInvestigator,
      'Researcher' => RDF::ORA.researcher,
      'Reviewer' => RDF::ORA.reviewer,
      'Sponsor' => RDF::ORA.sponsor,
      'Supervisor' => RDF::ORA.supervisor,
      'Translator' => RDF::ORA.translator
    },
    'data_steward' => {
      'Departmental Administrator' => RDF::ORA.departmentalAdministrator,
      'Designated Data Steward' => RDF::ORA.designatedDataSteward,
      'Head of Department' => RDF::ORA.headOfDepartment,
      'Head of Faculty' => RDF::ORA.headOfFaculty,
      'Head of Research Group' => RDF::ORA.headOfResearchGroup,  
      'Information/Data Manager' => RDF::ORA.dataManager,
      'Laboratory Manager' => RDF::ORA.laboratoryManager,         
      'Principal Investigator (PI)' => RDF::ORA.principalInvestigator,
      'Subject Librarian' => RDF::ORA.subjectLibrarian, 
      'Thesis Supervisor' => RDF::ORA.thesisSupervisor,
    },
    'dataset_agreement' => {
      'Data steward' => RDF::ORA.DataSteward
    }
  }

  config.role_labels = {}
  config.role_types.each do |k, v|
    config.role_labels.merge!(Hash[v.map{|k1,v1| [v1.to_s, k1]}])
  end

  config.oa_types = {
    "Article available freely on the publisher's website" => "Article available freely on the publisher's website",
    'Article should be made available freely in ORA' => 'Article should be made available freely in ORA',
    'Article available freely on the subject repository (like pubMed / arXiv)' => 'Article available freely on a subject repository (like pubMed / arXiv)',
    'Article is not available for free and needs a subscription' => 'Article is not available for free and needs a subscription',
    "I don't know" => "I don't know"
  }

  config.oa_reason = {
    'To publish in an open access journal which requires a charge' => 'To publish in an open access journal which requires a charge',
    'To forgo the embargo period and make my article available as open access immediately' => 'To forgo the embargo period and make my article available as open access immediately',
    'To make a special case for the article to be open access' => 'To make a special case for the article to be open access',
    'To support payment of other article charges' => 'To support payment of other article charges'
  }

  config.data_medium = {
    'Analog' => RDF::FABIO.AnalogStorageMedium,
    'Digital' => RDF::FABIO.DigitalStorageMedium
  }

  config.agreement_types = {
    'Principal' => 'Principal',
    'Individual' => 'Individual',
    'Bilateral' => 'Bilateral'
  }

  config.archiving_payment_options = {
    'Payment has already been made for archiving the data' => 'Paid',
    'Raise me an invoice for archiving the data' => 'To be invoiced',
    'Payment is not required' => 'Payment not required',
    'I need help with this' => 'Payment help'
  }

  config.draft_status = 'Draft'
  config.submitted_status = 'Submitted'
  config.assigned_status = 'Assigned'
  config.claimed_status = 'Claimed'
  config.escalated_status = 'Escalated'
  config.referred_status = 'Referred'
  config.rejected_status = 'Rejected'
  config.approved_status = 'Approved'
  config.failure_status = 'System failure'
  config.verified_status = 'System verified'
  config.migrated_status = 'Data migrated'
  config.published_status = 'Published'
  config.doi_status = 'DOI registered'

  config.workflow_status = [
    config.draft_status,
    config.submitted_status,
    config.assigned_status,
    config.claimed_status,
    config.escalated_status,
    config.referred_status,
    config.rejected_status,
    config.approved_status,
    config.failure_status,
    config.verified_status,
    config.migrated_status,
    config.published_status,
    config.doi_status
 ]

  config.user_edit_status = [config.draft_status, config.referred_status]

  config.next_workflow_status = {
    # The workflow status a reviewer can set.
    config.draft_status =>     [config.submitted_status],
    config.submitted_status => [config.assigned_status, config.claimed_status, config.escalated_status,
                                config.referred_status, config.rejected_status, config.approved_status],
    config.assigned_status =>  [config.escalated_status, config.referred_status, config.rejected_status, config.approved_status],
    config.claimed_status =>   [config.escalated_status, config.referred_status, config.rejected_status, config.approved_status],
    config.escalated_status => [config.assigned_status, config.claimed_status, config.referred_status, config.rejected_status, config.approved_status],
    config.referred_status =>  [config.submitted_status],
    config.approved_status =>  [config.assigned_status, config.claimed_status, config.escalated_status, config.referred_status, config.rejected_status],
    config.failure_status =>   [config.assigned_status, config.claimed_status, config.escalated_status,
                                config.referred_status, config.rejected_status, config.approved_status],
    config.published_status => [config.assigned_status, config.claimed_status, config.escalated_status,
                                config.referred_status, config.rejected_status, config.approved_status],
    config.doi_status =>       [config.assigned_status, config.claimed_status, config.escalated_status, config.referred_status, config.approved_status]
  }

  config.doi_event = 'Register doi'

  config.publish_to_queue_options = {
    # a workflow_status
    # occurence 
    #   can be a number or 'all'
    'article' => {
      config.approved_status => {'occurence' => 'all'}
    },
    'dataset' => {
      config.approved_status => {'occurence' => 'all'}
    },
    'thesis' => {
      config.approved_status => {'occurence' => 'all'}
    }
  }

  config.review_dashboard_status = config.workflow_status.reject{|s| s == config.draft_status}

  config.rt_server = 'https://support.bodleian.ox.ac.uk/'
  config.rt_queue = 'oraq'

  config.email_options = {
    # A workflow status
    # occurence 
    #   can be a number or 'all'
    # template 
    #   Naming of templates in line with rails convention for template partials 
    #   Example: /shared/emails/record_submitted looks for the file app/views/shared/emails/_record_submitted.html.erb
    # Subject 
    #   ID will be replaced by record_id
    #   TODO: Could replace subject string with a template. Needs code modification in rt_client.create_ticket
    'article' => {
      config.submitted_status => {'occurence' => 1, 'template' => '/shared/emails/record_submitted', 'subject' => 'Record ID submitted'},
      config.published_status => {'occurence' => 1, 'template' => '/shared/emails/record_published', 'subject' => 'Record ID published'}
    },
    'thesis' => {
      config.submitted_status => {'occurence' => 1, 'template' => '/shared/emails/record_submitted', 'subject' => 'Record ID submitted'},
      config.published_status => {'occurence' => 1, 'template' => '/shared/emails/record_published', 'subject' => 'Record ID published'}
    },
    'dataset' => {
      config.submitted_status => {'occurence' => 1, 'template' => '/shared/emails/record_submitted', 'subject' => 'Record ID submitted'},
      config.published_status => {'occurence' => 1, 'template' => '/shared/emails/record_published', 'subject' => 'Record ID published'}
    },
  }

  config.thesis_award_levels = {
      'Doctoral' => 'Doctoral',
      'Postdoctoral' => 'Postdoctoral',
      'Masters' => 'Masters',
      'Bachelors' => 'Bachelors',
  }

  config.thesis_degree_types = {
      'DPhil' => 'DPhil',
      'MSc' => 'MSc',
      'MSc by Research' => 'MSc by Research',
      'MPhil' => 'MPhil',
      'BPhil' => 'BPhil',
      'M.St.' => 'M.St.',
      'MLitt' => 'MLitt',
      'BLitt' => 'BLitt',
      'Bachelor of Divinity (B.D.)' => 'Bachelor of Divinity (B.D.)'
  }

  # Map hostnames onto Google Analytics tracking IDs
  # config.google_analytics_id = 'UA-99999999-1'
 
  # Specify the Fedora pid prefix:
  # config.id_namespace = 'sufia'
  
  config.contact_email = 'ora@bodleian.ox.ac.uk'
  config.from_email = 'no-reply@bodleian.ox.ac.uk'
  config.data_root_dir = '/data/'
  config.cud_base_url = 'http://10.0.0.203'

  # For migrating records
  config.ora_publish_queue_name = 'ora_publish'
  config.tmp_file_dir = 'tmp/files/'
end

