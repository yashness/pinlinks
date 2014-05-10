class Link < ActiveRecord::Base
  attr_accessible :actual_link , :tags , :description

  belongs_to :repo
  validates :repo_id, presence: true
  validates :actual_link, presence: true
  validates_uniqueness_of :actual_link, :scope => :repo_id


  def url
    /^http/.match(self.actual_link) ? self.actual_link : "http://#{self.actual_link}"
  end

end
