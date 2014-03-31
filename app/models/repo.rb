class Repo < ActiveRecord::Base
  attr_accessible :name , :tags , :user_id , :is_private

  belongs_to :user
  has_many :links
  validates :user_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, :scope => :user_id

  searchable do
    text :name, :tags
    integer :user_id
  end

end
