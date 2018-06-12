class HomeController < ApplicationController
	layout 'application', :except => :index
  def index
  	@engine = EngineState.first
    @sync_state = EngineState.find_by_name('sync')
  end

  def toggle
  	engine = EngineState.first
  	if engine.started?
  		engine.started = false
  	else
  		engine.started = true
  	end
  	engine.save
  	redirect_to root_path
  end

  def start_sync
    sync_state = EngineState.find_by_name('sync')
    unless sync_state.started?
      sync_state.started = true
      sync_state.save
  	  system('rake misc:manual_fetch_details RAILS_ENV=production &')
    end
  	redirect_to root_path
  end
end
