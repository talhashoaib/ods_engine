class EngineState < ActiveRecord::Base

	def started?
		started
	end

	def self.perform_sync
		
    match_dates = [Date.today.strftime('%y%m%d'), (Date.today + 1.days).strftime('%y%m%d'),
                   (Date.today + 2.days).strftime('%y%m%d'), (Date.today + 3.days).strftime('%y%m%d')]
    
    match_dates.each do |process_date|


      dateString = process_date
      ## Once we confirm the date string is valid, construct the url for the page of interest
      url = "http://www.oddsportal.com/matches/soccer/20#{dateString}/"
      #url = "http://www.oddsportal.com/soccer/england/premier-league/results/"
      
      puts "Launching web browser..."

      ods = GetOdds.new(url)
      
      matches = ods.getOddsPage(url)
      matches = matches.shuffle
      
      
      num_games = matches.length
      count = 0
      ah_anchor = "#ah;2"
      
      for mymatch in matches
        count += 1
        r = rand(1..2)
        puts "Trying next link in #{r} seconds...\n\n"
        sleep(r)
        ah_url = mymatch["url"] + ah_anchor

        
        ## Start getting the Asian Handicap for this particular match
        puts "Getting Asian Handicaps for match #{count} of #{num_games}"
        mymatch["asian_handicap"] = ods.getAsianHandicaps(ah_url)
        puts mymatch.inspect
        ## saving in DB

        m = OddMatch.find_by_odd_id(mymatch["id"])
        if m.present?
          m.asian_handicaps.destroy_all
        else
          m = OddMatch.new
          m.odd_id = mymatch["id"]
        end
        m.country = mymatch["country"]
        m.league = mymatch["league"]
        m.home_team = mymatch["home_team"]
        m.away_team = mymatch["away_team"]
        m.in_play = mymatch["in_play"]
        m.time = mymatch["time"]
        m.score = mymatch["score"]
        m.homewin = mymatch["homewin"]
        m.draw = mymatch["draw"]
        m.awaywin = mymatch["awaywin"]
        m.bs = mymatch["Bs"]
        m.url = ah_url
        m.match_day = "20#{dateString}".to_datetime
        m.save!

        if mymatch["asian_handicap"].present? && mymatch["asian_handicap"].is_a?(Array)
          mymatch["asian_handicap"].each do |asha|
            m.asian_handicaps.create!(name: asha["name"], home_team: asha["1"],
                                      away_team: asha["2"], payout: asha["payout"])
          end
        end



      end
      
      # browser.close
      # filename = dateString + '.json'
      # uncomment below
      # writeToFile(filename,'w',matches.to_json)
      # puts matches.inspect
    end

    sync_state = EngineState.find_by_name('sync')
    sync_state.started = false
    sync_state.save
    
	end
end
