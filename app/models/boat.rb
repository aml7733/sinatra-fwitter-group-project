class Boat < ActiveRecord::Base
  belongs_to :coach
  has_many :rowers  
end
