require './config/environment'

class CoachController < ApplicationController

  get '/coaches/signup' do
    erb :'/coaches/signup'
  end

  post '/coaches/signup' do
    if session[:id]
      flash[:message] = "Must log out before signing up."
      redirect '/coaches/logout'
    elsif params[:coach][:name] == "" || params[:coach][:password] == ""
      flash[:message] = "Cannot create coach with blank name or password."
      redirect '/coaches/signup'
    end
    @coach = Coach.create(params[:coach])
    session[:id] = @coach.id
    flash[:message] = "Signup successful."
    erb :'/coaches/myboats'
  end

  get '/coaches/login' do
    if session[:id]
      flash[:message] = "Must log out before logging in."
      redirect '/coaches/logout'
    end
    erb :'/coaches/login'
  end

  post '/coaches/login' do
    coach = Coach.find_by(name: params[:coach][:name])
    if coach && coach.authenticate(params[:coach][:password])
      session[:id] = coach.id
      flash[:message] = "Login successful."
      redirect '/coaches/myboats'
    else
      flash[:message] = "Login failed. Please try again."
      redirect '/coaches/login'
    end
  end

  get '/coaches/logout' do
    session.clear
    flash[:message] = "Logout successful."
    redirect '/'
  end

  get '/coaches/myboats' do
    if session[:id]
      erb :'/coaches/myboats'
    else
      flash[:message] = "Must be logged in to see coach's boat index."
      redirect '/coaches/login'
    end
  end
end
