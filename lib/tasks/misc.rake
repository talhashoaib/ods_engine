require 'watir-webdriver'
require 'nokogiri'
require 'json'


namespace :misc do

  desc "fetch soccer matches"
  task :fetch_details => :environment do 
    ## We check that the first argument is in the format 'yymmdd' and do some boundary checking.
    #dateString = checkDateString(args.to_s)
    dateString = "180602"
    ## Once we confirm the date string is valid, construct the url for the page of interest
    url = "http://www.oddsportal.com/matches/soccer/20#{dateString}/"
    #url = "http://www.oddsportal.com/soccer/england/premier-league/results/"
    
    puts "Launching web browser..."
    # Selenium::WebDriver::PhantomJS.path = '/Users/pierreyfl/Downloads/phantomjs-2.1.1-macosx/bin/phantomjs'
    # Selenium::WebDriver::PhantomJS.path = '/home/talha/projects/yallaposter-temp-repo/drivers/phantomjs/phantomjs-2.1.1-linux-x86_64/bin/phantomjs'
    # capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36")
    # driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => capabilities
    # browser = Watir::Browser.new driver

    


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
    end
    
    # browser.close
    filename = dateString + '.json'
    # uncomment below
    # writeToFile(filename,'w',matches.to_json)
    puts matches.inspect
  end
end