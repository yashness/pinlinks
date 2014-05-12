class Repo < ActiveRecord::Base
  attr_accessible :name , :tags , :user_id , :is_private

  belongs_to :user
  has_many :links
  # validates :user_id, presence: true
  validates :name, presence: true 
  validates :name, exclusion: { in: %W(p),
    message: "name cannot be 'p'" } 
  validates_uniqueness_of :name , :scope => :user_id
  validate :valid_repo_name
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
    x = self.user.profile_name rescue "p"
    y = self.name
    return "http://www.pinlinks.in/" + x + "/" + y
  end

  
  def valid_repo_name
    test = ( self.name.include?("\/") or self.name.include?("\\") ) rescue false 
    if test
      errors.add :email, "Repo Name you entered is invalid. Cant contain backslash or forward slash" unless self.name.blank?
    end
  end

  def self.session_repos(sesion_repo_names)
      session_repos = sesion_repo_names.split(",").uniq rescue []
      return Repo.where(:name => session_repos)
  end

end
#use rake sunspot:reindex to reindex everytime you change searchable block