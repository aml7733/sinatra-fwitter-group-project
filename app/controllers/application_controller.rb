require './config/environment'
require 'rack-flash'

class ApplicationController < Sinatra::Base
  enable :sessions
  use Rack::Flash

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
      flash[:message] = "Must be logged in to create a new boat."
      redirect '/coaches/login'
    end
    erb :'/boats/new'
  end

  post '/boats/new' do
    params[:boat].each_pair { |key, val| redirect '/boats/new' if val == "" }

    @boat = Boat.create(params[:boat])
    @boat.coach_id = session[:id]
    @boat.save
    erb :'/boats/edit'
  end

  post '/boats/edit' do

    @boat = Boat.find_by(name: params[:boat][:name])
    if @boat.coach_id == session[:id]
      erb :'/boats/edit'
    else
      redirect '/coaches/myboats'
    end

  end

  post '/boats/edit/rowers' do
    @boat = Boat.find_by(name: params[:boat][:name])
    if @boat.coach_id != session[:id]
      redirect '/coach/login'
    end
    binding.pry
    params[:rower].each do |rower_params|
      if rower_params[:name] != ""
        if Rower.find_by(rower_params)
          place = Rower.find_by(rower_params)
          place.boat_id = @boat.id
          place.save
        else
          place = Rower.create(rower_params) #create new rower for each non-empty rower box
          place.boat_id = @boat.id
          place.save
        end
      end
    end

    if params[:boat][:rower_ids]
      params[:boat][:rower_ids].each do |rower_id|
        place = Rower.find(rower_id)
        place.boat_id = @boat.id  #assign checked rowers to the boat being edited
        place.save
      end
    end
    redirect '/coaches/myboats'
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
