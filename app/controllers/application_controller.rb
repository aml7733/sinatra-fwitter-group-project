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

  get '/boats/new' do
    if !logged_in?
      redirect '/coaches/login'
    end
    erb :'/boats/new'
  end

  post '/boats/new' do
    binding.pry
    params[:boat].each_pair { |key, val| redirect '/boat/new' if val == "" }

    @boat = Boat.create(params[:boat])
    @boat.coach_id = session[:id]
    @boat.save
    erb :'/boats/edit'
  end

  post '/boats/edit' do
    @boat = Boat.find_by(name: params[:boat][:name])
    erb :'/boats/edit'
  end

  post '/boats/edit/rowers' do
    @boat = Boat.find_by(params[:boat])
    if @boat.coach_id != session[:id]
      redirect '/coach/login'
    end

    params[:rower].each do |rower_params|
      place = Rower.create(rower_params)
      place.boat_id = @boat.id
    end
    erb :'/coaches/myboats'
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
