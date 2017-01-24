class Coach < ActiveRecord::Base
  validates_presence_of :name, :password
  has_secure_password

  has_many :boats
  has_many :rowers, through: :boats
end
