class Repo < ActiveRecord::Base
  attr_accessible :name , :tags

  belongs_to :user
  has_many :links
  validates :user_id, presence: true
end
