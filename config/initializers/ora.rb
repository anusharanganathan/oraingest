# Returns an array containing the vhost 'CoSign service' value and URL
require 'vocabulary/camelot_vocabulary'

Sufia.config do |config|

    config.work_types = {
      "Article" => "Article",
      "Book" => "Book",
      "Conference Proceeding" => "Conference Proceeding",
      "Data" => "Data",
      "Thesis" => "Thesis",
      "Part of Book" => "Part of Book"
    }

    config.article_types = {
      "" => "",
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
    }

    config.book_types = {
      "" => "",
      "Book"=>"Book",
      "Book chapter" => "Book chapter",
      "Book review" => "Book review",
      "Book section" => "Book section",
      "Edited book" => "Edited book",
      "Edited volume" => "Edited volume",
      "Monograph" => "Monograph"
    }

    config.article_type_authorities = {
      "Article" => CAMELOT::article,
      "Discussion paper" => CAMELOT::discussionPaper,
      "Journal article" => CAMELOT::journalArticle,
      "Newsletter" => CAMELOT::newsletter,
      "Policy briefing" => CAMELOT::policyBriefing,
      "Press article" => CAMELOT::pressArticle,
      "Pamphlet" => CAMELOT::pamphlet,
      "Patent" => CAMELOT::patent,
      "Report" => CAMELOT::report,
      "Research Paper" => CAMELOT::researchPaper,
      "Review" => CAMELOT::review,
      "Technical report" => CAMELOT::technicalReport,
      "Working paper" => CAMELOT::workingPaper,
      "Other" => CAMELOT::article
    }

    config.publication_status = {
      "" => "",
      "Accepted" => "Accepted",
      "In Press" => "In Press",
      "Not published" => "Not published",
      "Published" => "Published",
      "Submitted" => "Submitted"
    }

    config.review_status = {
      "" => "",
      "Peer reviewed" => "Peer reviewed",
      "Reviewed" => "Reviewed",
      "Under review" => "Under review",
      "Not peer reviewed" => "Not peer reviewed"
    }

    config.rights_holder_group = {
      "" => "",
      "Sole authorship" => "Sole authorship",
      "Joint authorship" => "Joint authorship",
      "Other party" => "Other party",
      "Publisher has copyright" => "Publisher has copyright"
    }

    config.article_licenses = {
      "" => "",
      "CC Attribution (CC BY 2.5)" => "CC Attribution (CC BY 2.5)",
      "CC Attribution-NoDerivs (CC BY-ND 2.5)" => "CC Attribution-NoDerivs (CC BY-ND 2.5)",
      "CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)" => "CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)",
      "CC Attribution-NonCommercial (CC BY-NC 2.5)" => "CC Attribution-NonCommercial (CC BY-NC 2.5)",
      "CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)" => "CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)",
      "CC Attribution-ShareAlike (CC BY-SA 2.5)" => "CC Attribution-ShareAlike (CC BY-SA 2.5)",
      "GPL v2" => "GPL v2",
      "LGPL v2.1" => "LGPL v2.1",
      "MIT licence" => "MIT licence"
    }
 
    config.article_license_urls = {
      "CC Attribution (CC BY 2.5)" => "http://creativecommons.org/licenses/by/2.5/",
      "CC Attribution-NoDerivs (CC BY-ND 2.5)" => "http://creativecommons.org/licenses/by-nd/2.5/",
      "CC Attribution-NonCommercial-NoDerivs (CC BY-NC-ND 2.5)" => "http://creativecommons.org/licenses/by-nc-nd/2.5/",
      "CC Attribution-NonCommercial (CC BY-NC 2.5)" => "http://creativecommons.org/licenses/by-nc/2.5/",
      "CC Attribution-NonCommercial-ShareAlike (CC BY-NC-SA 2.5)" => "http://creativecommons.org/licenses/by-nc-sa/2.5/",
      "CC Attribution-ShareAlike (CC BY-SA 2.5)" => "http://creativecommons.org/licenses/by-sa/2.5/",
      "GPL v2" => "http://www.gnu.org/licenses/gpl.txt",
      "LGPL v2.1" => "http://www.gnu.org/licenses/lgpl.txt",
      "MIT licence" => "http://www.opensource.org/licenses/mit-license.php"
    }

    config.data_licenses = {
      "" => "",
      "ODC Attribution for data/databases (ODC-By)" => "ODC Attribution for data/databases (ODC-By)",
      "ODC Attribution Share-Alike for data/databases (ODC-ODbL)" => "ODC Attribution Share-Alike for data/databases (ODC-ODbL)",
      "ODC Public Domain for data/databases (PDDL)" => "ODC Public Domain for data/databases (PDDL)",
      "Open Government Licence (OGL)" => "Open Government Licence (OGL)",
      "OGL non commercial" => "OGL non commercial",
      "CC0 (CC Zero)" => "CC0 (CC Zero)",
      "Prepared licences" => "Prepared licences",
      "Bespoke licence" => "Bespoke licence"
    }
 
    config.data_license_urls = {
      "ODC Attribution for data/databases (ODC-By)" => "http://opendatacommons.org/licenses/by/",
      "ODC Attribution Share-Alike for data/databases (ODC-ODbL)" => "http://opendatacommons.org/licenses/odbl/",
      "ODC Public Domain for data/databases (PDDL)" => "http://opendatacommons.org/licenses/pddl/",
      "Open Government Licence (OGL)" => " http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/",
      "OGL non commercial" => "http://www.nationalarchives.gov.uk/doc/non-commercial-government-licence/",
      "CC0 (CC Zero)" => "http://creativecommons.org/choose/zero/"
    }

    config.attachment_types = {
      "Content" => "Content",
      "License agreement" => "License agreement",
      "Rights agreement with publisher" => "Rights agreement with publisher",
      "Personal correspondence to serve as agreement" => "Personal correspondence to serve as agreement"
    }
 
    config.embargo_release_methods = {
      "" => "",
      "Automatically lift the embargo" => "Automatically lift the embargo",
      "Consult me before lift of embargo" => "Consult me before lift of embargo"
    }

    config.relationship_types = {
      "" => "",
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

    config.embargo_options = [
      "Restricted until embargo end date",
      "Not visible",
      "Visible"  
    ]

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

end

