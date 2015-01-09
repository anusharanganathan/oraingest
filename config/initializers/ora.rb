# Returns an array containing the vhost 'CoSign service' value and URL
require 'vocabulary/camelot'
require 'vocabulary/ora'
require 'vocabulary/bibo'
require 'vocabulary/pso'
require 'vocabulary/fabio'

Sufia.config do |config|

  config.work_types = {
    "Article" => "Article",
    "Book" => "Book",
    "Conference Proceeding" => "Conference Proceeding",
    "Data" => "Data",
    "Thesis" => "Thesis",
    "Part of Book" => "Part of Book"
  }

  config.subtypes = {
    "article" => {
      "Article" => "Article",
      "Discussion paper" => "Discussion paper",
      "Journal article" => "Journal article",
      "Newsletter" => "Newsletter",
      "Policy briefing" => "Policy briefing",
      "Press article" => "Press article",
      "Pamphlet" => "Pamphlet",
      "Patent" => "Patent",
      "Report" => "Report",
      "Research Paper" => "Research Paper",
      "Review" => "Review",
      "Technical report" => "Technical report",
      "Working paper" => "Working paper",
      "Other" => "Other"
    },
    "book" => {
      "Book"=>"Book",
      "Book chapter" => "Book chapter",
      "Book review" => "Book review",
      "Book section" => "Book section",
      "Edited book" => "Edited book",
      "Edited volume" => "Edited volume",
      "Monograph" => "Monograph"
    },
    "dataset" => {
      "Dataset"=>"Dataset"
    }
  }

  config.type_authorities = {
    "article" => {
      "Article" => RDF::CAMELOT::article,
      "Discussion paper" => RDF::CAMELOT::discussionPaper,
      "Journal article" => RDF::CAMELOT::journalArticle,
      "Newsletter" => RDF::CAMELOT::newsletter,
      "Policy briefing" => RDF::CAMELOT::policyBriefing,
      "Press article" => RDF::CAMELOT::pressArticle,
      "Pamphlet" => RDF::CAMELOT::pamphlet,
      "Patent" => RDF::CAMELOT::patent,
      "Report" => RDF::CAMELOT::report,
      "Research Paper" => RDF::CAMELOT::researchPaper,
      "Review" => RDF::CAMELOT::review,
      "Technical report" => RDF::CAMELOT::technicalReport,
      "Working paper" => RDF::CAMELOT::workingPaper,
      "Other" => RDF::CAMELOT::article
    },
    "dataset" => {
      "Dataset" => RDF::CAMELOT::dataset,
    }
  }

  config.publication_status = {
    "Accepted" => "Accepted",
    "In Press" => "In Press",
    "Not published" => "Not published",
    "Published" => "Published",
    "Submitted" => "Submitted"
  }

  config.review_status = {
    "Peer reviewed" => "Peer reviewed",
    "Reviewed" => "Reviewed",
    "Under review" => "Under review",
    "Not peer reviewed" => "Not peer reviewed"
  }

  config.rights_holder_group = {
    "Sole authorship" => "Sole authorship",
    "Joint authorship" => "Joint authorship",
    "Other party" => "Other party",
    "Publisher has copyright" => "Publisher has copyright"
  }

  config.licenses = {
    "article" => {
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
    "dataset" => {
      "ODC Attribution for data/databases (ODC-By)" => "ODC Attribution for data/databases (ODC-By)",
      "ODC Attribution Share-Alike for data/databases (ODC-ODbL)" => "ODC Attribution Share-Alike for data/databases (ODC-ODbL)",
      "ODC Public Domain for data/databases (PDDL)" => "ODC Public Domain for data/databases (PDDL)",
      "Open Government Licence (OGL)" => "Open Government Licence (OGL)",
      "OGL non commercial" => "OGL non commercial",
      "CC0 (CC Zero)" => "CC0 (CC Zero)",
      "Bespoke licence" => "Bespoke licence"
    }
  }

  config.license_urls = {
    "CC Attribution (CC BY 2.5)" => "http://creativecommons.org/licenses/by/2.5/",
    "CC Attribution-NoDerivs (CC BY-ND 2.5)" => "http://creativecommons.org/licenses/by-nd/2.5/",
    "CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)" => "http://creativecommons.org/licenses/by-nc-nd/2.5/",
    "CC Attribution-NonCommercial (CC BY-NC 2.5)" => "http://creativecommons.org/licenses/by-nc/2.5/",
    "CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)" => "http://creativecommons.org/licenses/by-nc-sa/2.5/",
    "CC Attribution-ShareAlike (CC BY-SA 2.5)" => "http://creativecommons.org/licenses/by-sa/2.5/",
    "GPL v2" => "http://www.gnu.org/licenses/gpl.txt",
    "LGPL v2.1" => "http://www.gnu.org/licenses/lgpl.txt",
    "MIT licence" => "http://www.opensource.org/licenses/mit-license.php",
    "ODC Attribution for data/databases (ODC-By)" => "http://opendatacommons.org/licenses/by/",
    "ODC Attribution Share-Alike for data/databases (ODC-ODbL)" => "http://opendatacommons.org/licenses/odbl/",
    "ODC Public Domain for data/databases (PDDL)" => "http://opendatacommons.org/licenses/pddl/",
    "Open Government Licence (OGL)" => " http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/",
    "OGL non commercial" => "http://www.nationalarchives.gov.uk/doc/non-commercial-government-licence/",
    "CC0 (CC Zero)" => "http://creativecommons.org/choose/zero/"
  }

  config.attachment_types = {
    "article" => {
      "Content" => "Content",
      "License agreement" => "License agreement",
      "Rights agreement with publisher" => "Rights agreement with publisher",
      "Personal correspondence to serve as agreement" => "Personal correspondence to serve as agreement",
      "Publisher's APC or article charge request form" => "Publisher's APC or article charge request form"
    }
  }

  config.relationship_types = {
    "is a part of" => RDF::DC::isPartOf,
    "has constituent part" => RDF::DC::hasPart,
    "is a format of" => RDF::DC::isFormatOf, 
    "is referenced by" => RDF::DC::isReferencedBy,
    "references" => RDF::DC::references,
    "is replaced by" => RDF::DC::isReplacedBy,
    "replaces" => RDF::DC::replaces,
    "is required by" => RDF::DC::isRequiredBy,
    "requires" => RDF::DC::requires,
    "is a version Of" => RDF::DC::isVersionOf
  }

  config.embargo_release_methods = {
    "Automatically lift the embargo" => "Automatically lift the embargo",
    "Consult me before lift of embargo" => "Consult me before lift of embargo"
  }

  config.embargo_options = [
    "Open access",
    "Access restricted until embargo end date",
    "Closed access",
  ]

  config.embargo_reasons = {
    "article" => {
      "Publisher's requirement" => "Publishers requirement", 
      "Legal or ethical reasons" => "Legal or ethical reasons",
      "Commercial confidentiality" => "Commercial confidentiality",
      "National security" => "National security",
      "Conditional access only" => "Conditional access only"
    },
    "dataset" => {
      "Publisher's requirement" => "Publishers requirement", 
      "Legal or ethical reasons" => "Legal or ethical reasons",
      "Commercial confidentiality" => "Commercial confidentiality",
      "National security" => "National security",
      "Conditional access only" => "Conditional access only"
    }
  }

  config.role_types = {
    "article" => {
      "Author" => RDF::ORA.author,
      "Editor" => RDF::BIBO.editor,
      "Contributor" => RDF::DC.contributor
    },
    "thesis" => {
      "Author" => RDF::ORA.author,
      "Supervisor" => RDF::ORA.supervisor,
      "Examiner" => RDF::ORA.examiner,
      "Contributor" => RDF::DC.contributor
    },
    "dataset" => {
      "Adapter" => RDF::ORA.adapter,
      "Contributor" => RDF::DC.contributor,
      "Copyright holder" => RDF::ORA.copyrightHolder,
      "Creator" => RDF::DC.creator,
      "Depositor" => RDF::ORA.depositor,
      "Editor" => RDF::ORA.editor,
      "Examiner" => RDF::ORA.examiner,
      "Funder" => RDF::ORA.funder,
      "Performer" => RDF::ORA.performer,
      "Principal Investigator" => RDF::ORA.principalInvestigator,
      "Publisher" => RDF::DC.publisher,
      "Researcher" => RDF::ORA.researcher,
      "Reviewer" => RDF::ORA.reviewer,
      "Sponsor" => RDF::ORA.sponsor,
      "Supervisor" => RDF::ORA.supervisor,
      "Translator" => RDF::ORA.translator
    },
    "data_steward" => {
      "Principal Investigator" => RDF::ORA.principalInvestigator,
      "Creator" => RDF::DC.creator,
      "Head of Department" => RDF::ORA.headOfDepartment,
      "Head of Faculty" => RDF::ORA.headOfFaculty,
      "Head of Research Group" => RDF::ORA.headOfResearchGroup,  
    },
    "dataset_agreement" => {
      "Data steward" => RDF::ORA.DataSteward
    }
  }

  config.role_labels = {
    RDF::ORA.adapter.to_s => "Adapter",
    RDF::ORA.author.to_s => "Author",
    RDF::DC.contributor.to_s => "Contributor",
    RDF::ORA.copyrightHolder.to_s => "Copyright holder",
    RDF::DC.creator.to_s => "Creator",
    RDF::ORA.DataSteward.to_s => "Data steward",
    RDF::ORA.depositor.to_s => "Depositor",
    RDF::ORA.editor.to_s => "Editor",
    RDF::BIBO.editor.to_s => "Editor",
    RDF::ORA.examiner.to_s => "Examiner",
    RDF::ORA.funder.to_s => "Funder",
    RDF::ORA.headOfDepartment.to_s => "Head of Department",
    RDF::ORA.headOfFaculty.to_s => "Head of Faculty",
    RDF::ORA.headOfResearchGroup.to_s => "Head of Research Group",
    RDF::BIBO.owner.to_s => "Owner",
    RDF::ORA.performer.to_s => "Performer",
    RDF::ORA.principalInvestigator.to_s => "Principal Investigator",
    RDF::DC.publisher.to_s => "Publisher",
    RDF::ORA.researcher.to_s => "Researcher",
    RDF::ORA.reviewer.to_s => "Reviewer",
    RDF::ORA.sponsor.to_s => "Sponsor",
    RDF::ORA.supervisor.to_s => "Supervisor",
    RDF::ORA.translator.to_s => "Translator"
  }

  config.oa_types = {
    "Article available freely on the publisher's website" => "Article available freely on the publisher's website",
    "Article should be made available freely in ORA" => "Article should be made available freely in ORA",
    "Article available freely on the subject repository (like pubMed / arXiv)" => "Article available freely on a subject repository (like pubMed / arXiv)",
    "Article is not available for free and needs a subscription" => "Article is not available for free and needs a subscription",
    "I don't know" => "I don't know"
  }

  config.oa_reason = {
    "To publish in an open access journal which requires a charge" => "To publish in an open access journal which requires a charge",
    "To forgo the embargo period and make my article available as open access immediately" => "To forgo the embargo period and make my article available as open access immediately",
    "To make a special case for the article to be open access" => "To make a special case for the article to be open access",
    "To support payment of other article charges" => "To support payment of other article charges"
  }

  config.data_medium = {
    "Analog" => RDF::FABIO.AnalogStorageMedium,
    "Digital" => RDF::FABIO.DigitalStorageMedium
  }

  config.agreement_types = {
    "Principal" => "Principal",
    "Individual" => "Individual",
    "Bilateral" => "Bilateral"
  }

  config.archiving_payment_options = {
    "Payment has already been made for archiving the data" => "Paid",
    "Raise me an invoice for archiving the data" => "To be invoiced",
    "Payment is not required" => "Unfunded research",
    "I need help with this" => "Payment help"
  }

  config.workflow_status = {
    "Draft" => "Draft",
    "Submitted" => "Submitted",
    "Assigned" => "Assigned",
    "Claimed" => "Claimed",
    "Approved" => "Approved",
    "Escalated" => "Escalated",
    "Referred" => "Referred",
    "Rejected" => "Rejected",
    "Published" => "Published",
  }

  config.publish_to_queue_options = {
    # Possible states are: Draft, Submitted, Assigned, Claimed, Escalated, Referred, Rejected, Approved, System failure, Migrate, Published
    # occurence 
    #   can be a number or 'all'
    "article" => {
      "Approved" => {'occurence' => 'all'}
    },
    "dataset" => {
      "Approved" => {'occurence' => 'all'}
    },
    "thesis" => {
      "Approved" => {'occurence' => 'all'}
    }
  }

  config.rt_server = 'https://support.bodleian.ox.ac.uk/'
  config.rt_queue = 'oraq'

  config.email_options = {
    # Possible states are: Draft, Submitted, Assigned, Claimed, Escalated, Referred, Rejected, Approved, System failure, Migrate, Published
    # occurence 
    #   can be a number or 'all'
    # template 
    #   Naming of templates in line with rails convention for template partials 
    #   Example: /shared/emails/record_submitted looks for the file app/views/shared/emails/_record_submitted.html.erb
    # Subject 
    #   ID will be replaced by record_id
    #   TODO: Could replace subject string with a template. Needs code modification in rt_client.create_ticket
    "article" => {
      "Submitted" => {'occurence' => 1, 'template' => '/shared/emails/record_submitted', 'subject' => 'Record ID submitted'},
      "Published" => {'occurence' => 1, 'template' => '/shared/emails/record_published', 'subject' => 'Record ID published'}
    },
    "thesis" => {
      "Submitted" => {'occurence' => 1, 'template' => '/shared/emails/record_submitted', 'subject' => 'Record ID submitted'},
      "Published" => {'occurence' => 1, 'template' => '/shared/emails/record_published', 'subject' => 'Record ID published'}
    },
    "dataset" => {
      "Submitted" => {'occurence' => 1, 'template' => '/shared/emails/record_submitted', 'subject' => 'Record ID submitted'},
      "Published" => {'occurence' => 1, 'template' => '/shared/emails/record_published', 'subject' => 'Record ID published'}
    },
  }


  # Map hostnames onto Google Analytics tracking IDs
  # config.google_analytics_id = 'UA-99999999-1'
 
  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  # config.temp_file_base = '/home/developer1'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  # config.enable_ffmpeg = true
  
  # Specify the Fedora pid prefix:
  # config.id_namespace = "sufia"
  
  # Specify the path to the file characterization tool:
  # config.fits_path = "fits.sh"

  config.contact_email = "ora@bodleian.ox.ac.uk"
  config.from_email = "no-reply@bodleian.ox.ac.uk"
  config.data_root_dir = "/data/oradeposit/"
  config.cud_base_url = "http://dams-auth.bodleian.ox.ac.uk" #"http://10.0.0.203"
end

