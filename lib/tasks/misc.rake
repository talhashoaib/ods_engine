require 'watir-webdriver'
require 'nokogiri'
require 'json'


namespace :misc do

  desc "fetch soccer matches"
  task :fetch_details => :environment do
    sync_state = EngineState.find_by_name('sync')
    e = EngineState.first
    if e.started? && !sync_state.started?
      sync_state.started = true
      sync_state.save
      EngineState.perform_sync
    end
  end

  desc "manual fetch soccer matches"
  task :manual_fetch_details => :environment do 
    EngineState.perform_sync
  end
end