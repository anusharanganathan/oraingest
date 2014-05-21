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

