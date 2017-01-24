require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    enable :sessions
    set :session_secret, 'password_security'
    set :views, 'app/views'
  end

  get '/' do
    erb :index
  end

  helpers do
    def logged_in?
      !!session[:id]
    end

    def current_coach
      Coach.find(session[:id])
    end

    def current_coach_boats
      current_coach.boats
    end
  end
end
