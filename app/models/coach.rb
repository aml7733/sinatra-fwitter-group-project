require './config/environment'

class Coach < ActiveRecord::Base
  validates_presence_of :name, :password
  has_secure_password

  has_many :boats
  has_many :rowers, through: :boats

  def slug
    self.name.downcase.strip.gsub(" ", "-").gsub(/[^\w-]/, "")
  end

  def self.find_by_slug(slug)
    coachprime = nil
    self.all.each { |coach| coachprime = coach if coach.slug == slug }
    coachprime
  end
end
