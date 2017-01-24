require 'spec_helper'

describe ApplicationController do

  describe "Homepage" do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome")
    end
  end

  describe "Signup Page" do

    it 'loads the signup page' do
      get '/coaches/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs coach to boat index' do
      params = {
        :name => "skittles123",
        :password => "rainbows"
      }
      post '/coaches/signup', params
      expect(last_response.location).to include("/coaches/myboats")
    end

    it 'does not let a coach sign up without a name' do
      params = {
        :name => "",
        :password => "rainbows"
      }
      post '/coaches/signup', params
      expect(last_response.location).to include('/coaches/signup')
    end

    it 'does not let a coach sign up without a password' do
      params = {
        :name => "skittles123",
        :password => ""
      }
      post '/coaches/signup', params
      expect(last_response.location).to include('/coaches/signup')
    end

    it 'does not let a logged in user view the signup page' do
      coach = Coach.create(:name => "skittles123", :password => "rainbows")
      params = {
        :name => "skittles123",
        :password => "rainbows"
      }
      post '/coaches/signup', params
      session = {}
      session[:id] = coach.id
      get '/coaches/signup'
      expect(last_response.location).to include('/coaches/myboats')
    end
  end

  describe "login" do
    it 'loads the login page' do
      get '/coaches/login'
      expect(last_response.status).to eq(200)
    end

    it 'loads the boat index after login' do
      coach = Coach.create(:name => "becky567", :password => "kittens")
      params = {
        :name => "becky567",
        :password => "kittens"
      }
      post '/coaches/login', params
      expect(last_response.status).to eq(302)
      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Your Boats:")
    end

    it 'does not let coach view login page if already logged in' do
      coach = Coach.create(:name => "becky567", :password => "kittens")

      params = {
        :name => "becky567",
        :password => "kittens"
      }
      post '/coaches/login', params
      session = {}
      session[:id] = coach.id
      get '/coaches/login'
      expect(last_response.location).to include("/tweets")
    end
  end

  describe "logout" do
    it "lets a coach logout if they are already logged in" do
      coach = Coach.create(:name => "becky567", :password => "kittens")

      params = {
        :name => "becky567",
        :password => "kittens"
      }
      post '/coaches/login', params
      get '/coaches/logout'
      expect(last_response.location).to include("/coaches/login")

    end

    it 'does not let a coach logout if not logged in' do
      get '/coaches/logout'
      expect(last_response.location).to include("/")
    end

    it 'does not load create boats page if coach not logged in' do
      get '/boat/new'
      expect(last_response.location).to include("/coaches/login")
    end

    it 'does load create boats page if coach is logged in' do
      coach = Coach.create(:name => "becky567", :password => "kittens")


      visit '/coaches/login'

      fill_in('coach[name]', :with => "becky567")
      fill_in('coach[password]', :with => "kittens")
      click_button 'submit'
      expect(page.current_path).to eq('/coaches/myboats')
      click_button 'Create New Boat'
      expect(page.current_path).to eq('/boat/new')


    end
  end

  describe 'Coach show page' do
    it "shows all a single coach's boats" do
      coach = Coach.create(:name => "becky567", :password => "kittens")
      boat1 = Boat.create(name: "Shirley", weight: 200, num_seats: 8, coach_id: coach.id)
      boat2 = Boat.create(name: "Tiny", weight: 100, num_seats: 8, coach_id: coach.id)
      get "/coaches/#{coach.slug}"

      expect(last_response.body).to include("Shirley")
      expect(last_response.body).to include("Tiny")

    end
  end

  describe 'index action' do
    context 'logged in' do
      it 'lets a user view the tweets index if logged in' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "/tweets"
        expect(page.body).to include(tweet1.content)
        expect(page.body).to include(tweet2.content)
      end
    end


    context 'logged out' do
      it 'does not let a user view the tweets index if not logged in' do
        get '/tweets'
        expect(last_response.location).to include("/login")
      end
    end

  end



  describe 'new action' do
    context 'logged in' do
      it 'lets user view new tweet form if logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/new'
        expect(page.status_code).to eq(200)

      end

      it 'lets user create a tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/tweets/new'
        fill_in(:content, :with => "tweet!!!")
        click_button 'submit'

        user = User.find_by(:username => "becky567")
        tweet = Tweet.find_by(:content => "tweet!!!")
        expect(tweet).to be_instance_of(Tweet)
        expect(tweet.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user tweet from another user' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/tweets/new'

        fill_in(:content, :with => "tweet!!!")
        click_button 'submit'

        user = User.find_by(:id=> user.id)
        user2 = User.find_by(:id => user2.id)
        tweet = Tweet.find_by(:content => "tweet!!!")
        expect(tweet).to be_instance_of(Tweet)
        expect(tweet.user_id).to eq(user.id)
        expect(tweet.user_id).not_to eq(user2.id)
      end

      it 'does not let a user create a blank tweet' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit '/tweets/new'

        fill_in(:content, :with => "")
        click_button 'submit'

        expect(Tweet.find_by(:content => "")).to eq(nil)
        expect(page.current_path).to eq("/tweets/new")

      end
    end

    context 'logged out' do
      it 'does not let user view new tweet form if not logged in' do
        get '/tweets/new'
        expect(last_response.location).to include("/login")
      end
    end

  describe 'show action' do
    context 'logged in' do
      it 'displays a single tweet' do

        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "i am a boss at tweeting", :user_id => user.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'

        visit "/tweets/#{tweet.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Tweet")
        expect(page.body).to include(tweet.content)
        expect(page.body).to include("Edit Tweet")
      end
    end

    context 'logged out' do
      it 'does not let a user view a tweet' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "i am a boss at tweeting", :user_id => user.id)
        get "/tweets/#{tweet.id}"
        expect(last_response.location).to include("/login")
      end
    end
  end


  end

  describe 'edit action' do
    context "logged in" do
      it 'lets a user view tweet edit form if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(tweet.content)
      end

      it 'does not let a user edit a tweet they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        session = {}
        session[:user_id] = user1.id
        visit "/tweets/#{tweet2.id}/edit"
        expect(page.current_path).to include('/tweets')

      end

      it 'lets a user edit their own tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/1/edit'

        fill_in(:content, :with => "i love tweeting")

        click_button 'submit'
        expect(Tweet.find_by(:content => "i love tweeting")).to be_instance_of(Tweet)
        expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)

        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a text with blank content' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit '/tweets/1/edit'

        fill_in(:content, :with => "")

        click_button 'submit'
        expect(Tweet.find_by(:content => "i love tweeting")).to be(nil)
        expect(page.current_path).to eq("/tweets/1/edit")

      end
    end

    context "logged out" do
      it 'does not load let user view tweet edit form if not logged in' do
        get '/tweets/1/edit'
        expect(last_response.location).to include("/login")
      end
    end

  end

  describe 'delete action' do
    context "logged in" do
      it 'lets a user delete their own tweet if they are logged in' do
        user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit 'tweets/1'
        click_button "Delete Tweet"
        expect(page.status_code).to eq(200)
        expect(Tweet.find_by(:content => "tweeting!")).to eq(nil)
      end

      it 'does not let a user delete a tweet they did not create' do
        user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
        tweet1 = Tweet.create(:content => "tweeting!", :user_id => user1.id)

        user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
        tweet2 = Tweet.create(:content => "look at this tweet", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "becky567")
        fill_in(:password, :with => "kittens")
        click_button 'submit'
        visit "tweets/#{tweet2.id}"
        click_button "Delete Tweet"
        expect(page.status_code).to eq(200)
        expect(Tweet.find_by(:content => "look at this tweet")).to be_instance_of(Tweet)
        expect(page.current_path).to include('/tweets')
      end

    end

    context "logged out" do
      it 'does not load let user delete a tweet if not logged in' do
        tweet = Tweet.create(:content => "tweeting!", :user_id => 1)
        visit '/tweets/1'
        expect(page.current_path).to eq("/login")
      end
    end

  end


end
