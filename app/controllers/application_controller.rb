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

  get '/boat/new' do
    if !logged_in?
      redirect '/coaches/login'
    end
    erb :'/boats/new'
  end

  post '/boat/new' do
    params[:boat].each_pair { |key, val| redirect '/boat/new' if val == "" }

    boat = Boat.create(params[:boat])
    boat.coach_id = session[:id]
    redirect '/coaches/myboats'
  end

  post '/boat/edit' do
    @boat = Boat.find_by(params[:boat])
    erb :'/boats/edit'
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
