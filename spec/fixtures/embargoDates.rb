require 'ora/embargo_date'

id = "info:fedora/test"
datePublished = ""

#ans = Ora.validateEmbargoDates(params, id, datePublished)

params = [
  {
    #1. open access
    :embargoStatus => "Open access", 
    :embargoDate => [{
      :start => [{:date => "", :label => ""}],
      :duration => [{:years => "", :months => ""}],
      :end => [{:date => "", :label => ""}]
    }],
    :embargoReason =>  "",
    :embargoRelease => ""
  }, {
    #2. closed access
    :embargoStatus => "Closed access", 
    :embargoDate => [{
      :start => [{:date => "", :label => "Today"}],
      :duration => [{:years => "", :months => ""}],
      :end => [{:date => "12-02-1978", :label => ""}]
    }],
    :embargoReason =>  "",
    :embargoRelease => ""
  }, {
    #3. embargoed to specified end date
    :embargoStatus => "Embargoed", 
    :embargoDate => [{
      :start => [{:date => "", :label => "Today"}],
      :duration => [{:years => "", :months => ""}],
      :end => [{:date => "12-02-2078", :label => ""}]
    }],
    :embargoReason =>  "",
    :embargoRelease => ""
  }, {
    #4. embargoed from today for a given duration with month and year defined
    :embargoStatus => "Embargoed", 
    :embargoDate => [{
      :start => [{:date => "", :label => "Today"}],
      :duration => [{:years => "3", :months => "10"}],
      :end => [{:date => "", :label => ""}]
    }],
    :embargoReason =>  "",
    :embargoRelease => ""
  }, {
    #5. embargoed from  publication date for a given duration with year defined
    :embargoStatus => "Embargoed", 
    :embargoDate => [{
      :start => [{:date => "", :label => "Publication date"}],
      :duration => [{:years => "3", :months => ""}],
      :end => [{:date => "", :label => ""}]
    }],
    :embargoReason =>  "",
    :embargoRelease => ""
  }, {
    #6. embargoed from given date for a given duration with month defined
    :embargoStatus => "Embargoed", 
    :embargoDate => [{
      :start => [{:date => "2014-1", :label => ""}],
      :duration => [{:years => "", :months => "10"}],
      :end => [{:date => "", :label => ""}]
    }],
    :embargoReason =>  "",
    :embargoRelease => ""
  }
]
