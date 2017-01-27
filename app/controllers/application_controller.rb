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

  get '/boats/index' do
    @all_boats = Boat.all
    erb :'/boats/index'
  end

  get '/boats/new' do
    if !logged_in?
      flash[:message] = "Must be logged in to create a new boat."
      redirect '/coaches/login'
    end
    erb :'/boats/new'
  end

  post '/boats/new' do
    params[:boat].each_pair do |key, val|
      flash[:message] = "Cannot create boat with empty values."
      redirect '/boats/new' if val == ""
    end

    @boat = Boat.create(params[:boat])
    @boat.coach_id = session[:id]
    @boat.save
    flash[:message] = "Successfully created new boat.  Please add rowers."
    erb :'/boats/edit'
  end

  post '/boats/edit' do
    @boat = Boat.find_by(name: params[:boat][:name])
    unless @boat
      flash[:message] = "The boat you entered either doesn't exist, or isn't yours."
      redirect '/coaches/myboats'
    end
    if @boat.coach_id == session[:id]
      erb :'/boats/edit'
    else
      flash[:message] = "Only the coach who created the boat may edit said boat."
      redirect '/coaches/myboats'
    end
  end

  post '/boats/edit/rowers' do
    @boat = Boat.find_by(name: params[:boat][:name])
    if @boat.coach_id != session[:id]
      flash[:message] = "Only the coach who created the boat may edit said boat."
      redirect '/coach/login'
    end

    Rower.all.each do |rower|
      if rower.boat_id == @boat.id #remove 'un-checked' rowers
        rower.boat_id = nil
        rower.save
      end
    end

    params[:rower].each do |rower_params|
      if rower_params[:name] != ""
        if Rower.find_by(rower_params)
          place = Rower.find_by(rower_params) #check to see if rower entered in text box already exists
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

    params[:boat].delete("rower_ids")
    @boat.update(params[:boat])
    flash[:message] = "Successfully updated boat."
    redirect '/coaches/myboats'
  end

  post '/boats/delete' do
    @boat = Boat.find_by(params[:boat])
    @boat.destroy
    flash[:message] = "Boat successfully deleted."
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
