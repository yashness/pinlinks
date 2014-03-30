class Repo < ActiveRecord::Base
  attr_accessible :name , :tags , :user_id

  belongs_to :user
  has_many :links
  validates :user_id, presence: true
  validates :name, presence: true, 
  					  uniqueness: true
  validates :name, presence: true, 
  					  format: {
  					  	with: /\A[a-zA-Z\-\_]+\Z/,
  					  	message: 'Must be formatted correctly. Dont include spaces'
  					  }
end
