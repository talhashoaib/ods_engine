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
  	redirect_to :back
  end
end
