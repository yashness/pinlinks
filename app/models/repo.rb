class Repo < ActiveRecord::Base
  attr_accessible :name , :tags , :user_id , :is_private

  belongs_to :user
  has_many :links
  # validates :user_id, presence: true
  validates :name, presence: true
  validates_uniqueness_of :name, :scope => :user_id

  searchable do
    text :name, :boost => 3
    text :tags
    integer :user_id
	text :links do
      links.map { |link| link.tags }
    end
	text :links do
      links.map { |link| link.actual_link }
    end
  end

  def url
    x = self.user.profile_name rescue "no_user"
    y = self.name
    return "http://www.pinlinks.com/" + x + "/" + y
  end



end
#use rake sunspot:reindex to reindex everytime you change searchable block