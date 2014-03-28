class Link < ActiveRecord::Base
  attr_accessible :actual_link , :tags , :description

  belongs_to :repo
  validates :repo_id, presence: true
end
