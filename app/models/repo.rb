class Repo < ActiveRecord::Base
  attr_accessible :name , :tags , :user_id

  belongs_to :user
  has_many :links
  validates :user_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, :scope => :user_id
end
