require './config/environment'

class CoachController < ApplicationController

  get '/coaches/signup' do
    erb :'/coaches/signup'
  end

  post '/coaches/signup' do
    if session[:id]
      redirect '/coaches/logout'
    end
    binding.pry
    @coach = Coach.create(params[:coach])
    session[:id] = @coach.id
    erb :'/coaches/myboats'
  end

  get '/coaches/login' do
    erb :'/coaches/login'
  end

  post '/coaches/login' do
    @coach = Coach.find_by(name: params[:coach][:name])
    session[:id] = @coach.id
    redirect '/coaches/myboats'
  end

  get '/coaches/myboats' do
    if session[:id]
      erb :'/coaches/myboats'
    end
    redirect '/coaches/login'
  end
end
