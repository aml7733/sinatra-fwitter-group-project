require './config/environment'

class CoachController < Sinatra::Base

  get '/coaches/signup' do
    erb :'coaches/signup'
  end

  post '/coaches/signup' do
    binding.pry
    @coach = Coach.create(params[coach])
  end

  get '/coaches/login' do
    erb :'/coaches/login'
  end
end
