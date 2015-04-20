module Ora

  module_function

  def validateEmbargoDates(params, id, datePublished)
    # If endDate is given
    # 	endDateType = Stated
    #   endDate = date
    # If duration is given and startDate is today
    #   startDateType = Date
    #   endDateType = Defined
    #	endDate = today's date + duration
    # If duration is given and startDate is particular date
    #   startDateType = Date
    #   endDateType = Defined
    #	endDate = date + duration
    # If duration is given and startDate is publication date
    #   startDateType = Publication date
    #   If publication date is known 
    #     endDateType = Defined
    #	  endDate = publication date + duration
    #   If publication date is not known
    #     endDateType = Approximate
    #	  endDate = today + duration
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
      if !params[:embargoDate].nil?
        if !params[:embargoDate][:end].nil?
          if !params[:embargoDate][:end][:date].nil? && !params[:embargoDate][:end][:label].nil? && params[:embargoDate][:end][:label] == "Stated"
            begin
              endDate = Time.parse(params[:embargoDate][:end][:date])
            rescue
              endDate = nil
            end
          end
        end
        if !endDate.nil?
          vals[:embargoDate][0][:end][0]['id'] = "%s#embargoEnd"% id
          vals[:embargoDate][0][:end][0][:date] = endDate.strftime("%d %b %Y")
          vals[:embargoDate][0][:end][0][:label] = "Stated"
        else
          # get the start date
          if !params[:embargoDate][:start].nil?
            if params[:embargoDate][:start][:label] == "Today"
              startDateType = "Date"	
              startDate = Time.now
            elsif params[:embargoDate][:start][:label] == "Publication date"
              startDateType = "Publication date"
              begin
                startDate = Time.parse(datePublished)          
              rescue
                startDate = nil
              end
            elsif !params[:embargoDate][:start][:date].nil?
              startDateType = "Date"
              begin
                startDate = Time.parse(params[:embargoDate][:start][:date])
              rescue
                startDate = nil
              end
            end
          end
          # Get the duration
          if !params[:embargoDate][:duration].nil?
            if params[:embargoDate][:duration][:years]
              numberOfYears = params[:embargoDate][:duration][:years].to_i
            end
            if params[:embargoDate][:duration][:months]
              numberOfMonths = params[:embargoDate][:duration][:months].to_i
            end
          end
          if (!numberOfYears.nil? || !numberOfMonths.nil?) && (numberOfYears > 0 || numberOfMonths > 0)
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
  
