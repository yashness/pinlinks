require 'subscribe_on_mail_chimp'
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  devise :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :profile_name
  # attr_accessible :title, :body
  validates :profile_name, presence: true, 
  					  uniqueness: true,
  					  format: {
  					  	with: /\A[a-zA-Z\-\_]+\Z/,
  					  	message: 'Must be formatted correctly.'
  					  }
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true#, :confirmation => true
  # validates :password_confirmation, :presence => true, :if => '!password.nil?'
  has_many :repos  

  after_create do
    email = self.email
    profile_name = self.profile_name
    double_optin = true
    Delayed::Job.enqueue(SubscribeOnMailChimp.new(email , profile_name , double_optin))
  end

  def self.find_for_facebook_oauth(auth)
    where(auth.slice(:provider, :authid)).first_or_create do |user|
      user.provider = auth.provider
      user.authid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end

  def self.find_for_google_oauth2(auth)
    where(auth.slice(:provider, :authid)).first_or_create do |user|
      user.provider = auth.provider
      user.authid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.profile_name = user.email.split('@').first
    end
  end

end
