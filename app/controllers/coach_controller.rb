require './config/environment'

class CoachController < ApplicationController

  get '/coaches/signup' do
    erb :'/coaches/signup'
  end

  post '/coaches/signup' do
    binding.pry
    @coach = Coach.create(params[:coach])
    session[:id] = @coach.id
    erb :'/coaches/myboats'
  end

  get '/coaches/login' do
    erb :'/coaches/login'
  end
end
