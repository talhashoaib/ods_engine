class HomeController < ApplicationController
	layout 'application', :except => :index
  def index
  	@engine = EngineState.first
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
  	system('rake misc:manual_fetch_details RAILS_ENV=production &')
  	redirect_to root_path
  end
end
