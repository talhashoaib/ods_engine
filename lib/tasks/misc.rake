require 'watir-webdriver'
require 'nokogiri'
require 'json'


namespace :misc do

  desc "fetch soccer matches"
  task :fetch_details => :environment do 
    e = EngineState.first
    if e.started?
      EngineState.perform_sync
    end
  end

  desc "manual fetch soccer matches"
  task :manual_fetch_details => :environment do 
    EngineState.perform_sync
  end
end