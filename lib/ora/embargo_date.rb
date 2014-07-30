module Ora

  module_function

  def validateEmbargoDates(params, id, datePublished)
    vals = {
      'id' => "%s#accessRights"% id,
      :embargoStatus => nil, 
      :embargoDate => [{
        'id' => nil,
        :start => [{:date => nil, :label => nil, 'id' => nil}],
        :duration => [{:years => nil, :months => nil, 'id' => nil}],
        :end => [{:date => nil, :label => nil, 'id' => nil}]
      }],
      :embargoReason =>  nil,
      :embargoRelease => nil
    }
  
    # embargoStatus = open
    if params[:embargoStatus] == "Open access" 
      vals[:embargoStatus] = params[:embargoStatus]
    elsif params[:embargoStatus] == "Closed access"
      vals[:embargoStatus] = params[:embargoStatus]
      if !params[:embargoReason].nil? && !params[:embargoReason].empty?
        vals[:embargoReason] = params[:embargoReason]
      end
      if !params[:embargoRelease].nil? && !params[:embargoRelease].empty? && Sufia.config.embargo_release_methods.include?(params[:embargoRelease])
        vals[:embargoRelease] = params[:embargoRelease]
      end
    elsif params[:embargoStatus] == "Embargoed"
      vals[:embargoStatus] = params[:embargoStatus]
      vals[:embargoDate][0]['id'] = "%s#embargoDate"% id
      if !params[:embargoReason].nil? && !params[:embargoReason].empty?
        vals[:embargoReason] = params[:embargoReason]
      end
      if !params[:embargoRelease].nil? && !params[:embargoRelease].empty? && Sufia.config.embargo_release_methods.include?(params[:embargoRelease])
        vals[:embargoRelease] = params[:embargoRelease]
      end
      startDate = nil
      startDateType = nil
      endDate = nil
      endDateType = nil
      numberOfYears = nil
      numberOfMonths = nil
      if !params[:embargoDate].nil? || !params[:embargoDate][0].nil?
        if !params[:embargoDate][0][:end].nil? && !params[:embargoDate][0][:end][0].nil? && !params[:embargoDate][0][:end][0][:date].nil?
          begin
            endDate = Time.parse(params[:embargoDate][0][:end][0][:date])
          rescue
            endDate = nil
          end
        end
        if !endDate.nil?
          vals[:embargoDate][0][:end][0]['id'] = "%s#embargoEnd"% id
          vals[:embargoDate][0][:end][0][:date] = endDate.strftime("%d %b %Y")
          vals[:embargoDate][0][:end][0][:label] = "Stated"
        else
          # get the start date
          if !params[:embargoDate][0][:start].nil? && !params[:embargoDate][0][:start][0].nil?
            if params[:embargoDate][0][:start][0][:label] == "Today"
              startDateType = "Date"	
              startDate = Time.now
            elsif params[:embargoDate][0][:start][0][:label] == "Publication date"
              startDateType = "Publication date"
              begin
                startDate = Time.parse(datePublished)          
              rescue
                startDate = nil
              end
            elsif !params[:embargoDate][0][:start][0][:date].nil?
              startDateType = "Date"
              begin
                startDate = Time.parse(params[:embargoDate][0][:start][0][:date])
              rescue
                startDate = nil
              end
            end
          end
          # Get the duration
          if !params[:embargoDate][0][:duration].nil? && !params[:embargoDate][0][:duration][0].nil?
            if params[:embargoDate][0][:duration][0][:years]
              numberOfYears = params[:embargoDate][0][:duration][0][:years].to_i
            end
            if params[:embargoDate][0][:duration][0][:months]
              numberOfMonths = params[:embargoDate][0][:duration][0][:months].to_i
            end
          end
          if !numberOfYears.nil? || !numberOfMonths.nil?
            if startDate.nil?
              endDateType = "Approximate"
              startDate = Time.now
            else
              endDateType = "Defined"
            end
            endDate = startDate + numberOfYears.years + numberOfMonths.months
            vals[:embargoDate][0][:start][0]['id'] = "%s#embargoStart"% id
            vals[:embargoDate][0][:start][0][:date] = startDate.strftime("%d %b %Y")
            vals[:embargoDate][0][:start][0][:label] = startDateType
            vals[:embargoDate][0][:duration][0]['id'] = "%s#embargoDuration"% id
            vals[:embargoDate][0][:duration][0][:years] = numberOfYears.to_s
            vals[:embargoDate][0][:duration][0][:months] = numberOfMonths.to_s
            vals[:embargoDate][0][:end][0]['id'] = "%s#embargoEnd"% id
            vals[:embargoDate][0][:end][0][:date] = endDate.strftime("%d %b %Y")
            vals[:embargoDate][0][:end][0][:label] = endDateType
          end #if duration
        end #if end date
      end #if embargoDate
    end # if embargoed
    vals
  end #validateEmbargoDates
end #module ORA
  
