## getOdds.rb
## v1.0.0
## Author: Pierre Yam
## E-mail: pierreyam@icloud.com

## Script to scrape match odds from
## http://www.oddsportal.com/

## Usage: getOdds.rb yymmdd
## Built for Ruby 2.3.1

## Requirements:
## Nokogiri - http://www.nokogiri.org/ - For parsing and extraction
## Watir - http://watir.github.io/ - Browser automation and web testing
## PhantomJS - http://phantomjs.org/ - Full stack Webkit (headless browser)

require 'watir-webdriver'
require 'nokogiri'
require 'json'


class GetOdds
	## This script will wait a random number between
	## MIN_WAIT and MAX_WAIT seconds between page requests
	MIN_WAIT = 1.0
	MAX_WAIT = 2.0
	MAX_RETRIES = 5

	def initialize(url)
    # @options = options.symbolize_keys
    # @logger = Utils.get_logger('fetching.log')
    # @logger.info "---------------- #{options}"
    # puts options.inspect
    # @action = options["action"]
    # @username = @options[:username]
    # @password = @options[:password]
    # @site = @options[:site]

    # headless = Headless.new
    # headless.start

    # @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:8001'

    Selenium::WebDriver::PhantomJS.path = '/home/talha/projects/yallaposter-temp-repo/drivers/phantomjs/phantomjs-2.1.1-linux-x86_64/bin/phantomjs'
	  capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36")
	  driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => capabilities
	  @client  = Watir::Browser.new driver
    
    # @client =  Watir::Browser.new :phantomjs, :args => ['--ssl-protocol=tlsv1']
    # @urls = get_urls(@site)
    # @client = Watir::@client.new :chrome

    # @client.window.resize_to(1024,768)
    
    # @client.goto @urls[:login]
    # @is_logged_in = eval "#{@site}_authenticate"

    # if @is_logged_in
    #   eval "#{@site}_fetch_data"
    # end
  end

	def getPage(url)
		retries = 0
		begin
			###		puts "Launching web @client..."
			##		browser = Watir::@client.new :phantomjs
			
			puts "Getting page from: \n#{url}\n"
			@client.goto url
			
		rescue Exception => e
			puts "Could not connect to site: \n#{url}"
			if retries < MAX_RETRIES
				retries += 1
				r = (rand(MIN_WAIT..MAX_WAIT) + 1.1) ** retries
				puts "Retrying #{retries} of #{MAX_RETRIES} in #{r} seconds...\n"
				sleep(r)
				retry
			else
				puts "Could not connect to site: \n#{url}\n"
				raise "Giving up on the server after #{retries} retries. Got error: #{e.message}"
				@client.close
				return nil
			end
		end
		_HTMLpage = @client.html
		@client.close
		return _HTMLpage
	end

	def writeToFile(filename,mode,data)
		aFile = File.new(filename, mode)
		if aFile
			aFile.syswrite(data)
			aFile.close
			puts "DONE"
		else
			puts "Unable to open file #{filename} for writing!"
		end
	end

	def checkDateString(dateString)
		begin
			if dateString.length != 6
				raise 'Date string improper length'
			end
			year = Integer(dateString[0,2])
			month = Integer(dateString[2,2])
			day = Integer(dateString[4,2])
			short_months = [2,4,6,9,11]
			if month > 12 or month < 1
				raise 'Invalid month in date string'
			end
			if day > 31 or day < 1 or (short_months.include? month) or (month == 2 and day > 29)
			raise 'Day out of range for given month'
		end
		rescue
			puts "Error: Invalid date string"
			puts "Usage: " + File.basename($0) + " yymmdd"
			exit(1)
		end
		return dateString
	end

	def getOddsPage(url)

		retries = 0
		begin

			##		puts "Launching web @client..."
			##		browser = Watir::@client.new :phantomjs

			puts "Getting page from: \n#{url}\n"
			@client.goto url

			
			puts "Waiting for page content to load..."
			until @client.table(:class=>" table-main").exists? do sleep 1 end
			## Checks every second to see if the page to see if the element has been loaded in
			
		rescue Exception => e
			puts "Could not connect to site: \n#{url}"
			if retries < MAX_RETRIES
				retries += 1
				r = (rand(MIN_WAIT..MAX_WAIT) + 1.1) ** retries
				puts "Retrying #{retries} of #{MAX_RETRIES} in #{r} seconds...\n"
				sleep(r)
				retry
			else
				puts "Could not connect to site: \n#{url}\n"
				raise "Giving up on the server after #{retries} retries. Got error: #{e.message}"
				@client.close
				exit(1)
			end
		end
		
		puts "Content found!"
		_HTMLpage = @client.html
		
		## Convert the browser HTML for parsing with Nokogiri
		doc = Nokogiri::HTML(_HTMLpage)

		## Here we use xpathing to grab every row with a game in the table omitting header rows
		#rows = doc.xpath('//table[@class=" table-main"]/tbody//tr[@class != "dark center" and @class != "center nob-border" and @class != "table-dummyrow"]')
	  
	  ## For archived odds
	  rows = doc.xpath('//table[@class=" table-main"]/tbody//tr[@class != "dark center" and @class != "center nob-border" and @class != "table-dummyrow"]')

		## Count the number of rows/games found and inform the user.
		num_games = String(rows.length)
		puts "#{num_games} games found."
	  
	  if rows.length > 250
	    rows = rows.first(250)
	    puts "Getting 250 games"
	  end
	  
		matches = rows.collect do |row|
			match = {}
			match["id"] = row.at_xpath('.//td[2]//a[last()]/@href').to_s.strip.split('-').last.split('/').first
	    match["country"] = row.at_xpath('.//td[2]//a[last()]/@href').to_s.strip.split('/')[2].capitalize
	    match["league"] = row.at_xpath('.//td[2]//a[last()]/@href').to_s.strip.split('/')[3].gsub("-", " ").capitalize
			teams = row.xpath('.//td[2]//a[last()]//text()').to_s.strip.split(' - ')
			match["home_team"] = teams.first.strip
			match["away_team"] = teams.last.strip
			match["in_play"] = row.xpath('.//td[3]/a/span[@class="live-odds-ico-prev"]').any?
			[
				["time", './/td[1]/text()'],
				["score", './/td[3]/text()'],
				["homewin", './/td[last()-3]/@xodd'],
				["draw", './/td[last()-2]/@xodd'],
				["awaywin", './/td[last()-1]/@xodd'],
				["Bs", './/td[last()]/text()'],
			].each do |name, xpath|
				match[name] = row.at_xpath(xpath).to_s.strip
			end
			
			## Construct the URL for the Asian Handicaps pages
			baseURL = 'http://www.oddsportal.com'
			rel_link = row.at_xpath('.//td[2]//a[last()]/@href').to_s.strip
			abs_link = baseURL + rel_link
			match["url"] = abs_link
			match
		end
		return matches
	end

  def getAsianHandicaps(url)
		retries = 0
		begin

			##		puts "Launching web @client..."
			##		browser = Watir::@client.new :phantomjs

			puts "Getting page from: \n#{url}\n"
			@client.goto url
			##click on EU odds
			
		rescue Exception => e
			if retries < MAX_RETRIES
				retries += 1
				r = (rand(MIN_WAIT..MAX_WAIT) + 1.1) ** retries
				puts "Failed to get url: \n#{url}\n"
				puts "Trying next link in #{r} seconds...\n\n"
				sleep(r)
				puts "Retrying: #{retries} of #{MAX_RETRIES} max\n"
				retry
			else
				puts "Giving up on the url after #{retries} retries. Got error: #{e.message}"
				writeToFile('failedlinks.txt','a',url)
				return nil
			end
		end
		
		puts "Waiting for page content to load...."
	  sleep 3
	  if @client.div(:class=>"message-info").exists?
	    puts "No Content"
	    return nil
	  else
		until @client.div(:class=>"table-container").exists? do sleep 1 end
			
		puts "Content found!"
		_HTMLpage = @client.html
		
		## Once the content is loaded we convert the HTML using Nokogiri then use xpath to extract the data rows
		doc = Nokogiri::HTML(_HTMLpage)
		rows = doc.xpath('//div[@id="odds-data-table"]//div[@class="table-container"]/div')
		
		## Count the handicap items found and inform user.
		handicaps = String(rows.length)
		puts "#{handicaps} Asian Handicap(s) found.\n\n"

		## Aggregate the Asian Handicap info as an array and and add it to the match's Ruby hash
		asian_handicap = rows.collect do |row|
			ah = {}
			[
				["name", 'strong[1]/a/text()'],
				["1", 'span[3]/a/text()'],
				["2", 'span[2]/a/text()'],
				["payout", 'span[1]/text()'],
			].each do |name, xpath|
				ah[name] = row.at_xpath(xpath).to_s.strip
			end
			ah
		end
		return asian_handicap
	end
end
end


# def main(date)
	
	
# end


