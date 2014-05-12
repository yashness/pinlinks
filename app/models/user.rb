require 'subscribe_on_mail_chimp'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile_name
  # attr_accessible :title, :body
  validates :profile_name, presence: true, 
  					  uniqueness: true,
  					  format: {
  					  	with: /\A[a-zA-Z\-\_]+\Z/,
  					  	message: 'Must be formatted correctly.'
  					  }
  has_many :repos  

  after_create do
    email = self.email
    profile_name = self.profile_name
    double_optin = true
    Delayed::Job.enqueue(SubscribeOnMailChimp.new(email , profile_name , double_optin))
  end

end
