class UserFork < ActiveRecord::Base
  attr_accessible :user_id, :repo_id , :id
  belongs_to :user
  belongs_to :repo

end
