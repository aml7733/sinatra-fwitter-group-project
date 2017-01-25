require './config/environment'

class CoachController < ApplicationController

  get '/coaches/signup' do
    erb :'/coaches/signup'
  end

  post '/coaches/signup' do
    if session[:id]
      redirect '/coaches/logout'
    elsif params[:coach][:name] == "" || params[:coach][:password] == ""
      redirect '/coaches/signup'
    end
    @coach = Coach.create(params[:coach])
    session[:id] = @coach.id
    erb :'/coaches/myboats'
  end

  get '/coaches/login' do
    if session[:id]
      redirect '/coaches/logout'
    end
    erb :'/coaches/login'
  end

  post '/coaches/login' do
    coach = Coach.find_by(name: params[:coach][:name])
    if coach && coach.authenticate(params[:coach][:password])
      session[:id] = coach.id
      redirect '/coaches/myboats'
    else
      redirect '/coaches/login'
    end
  end

  get '/coaches/logout' do
    session.clear
    redirect '/'
  end

  get '/coaches/myboats' do
    if session[:id]
      erb :'/coaches/myboats'
    end
    redirect '/coaches/login'
  end
end