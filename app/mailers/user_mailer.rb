class UserMailer < ActionMailer::Base
  default from: "admin@pinlinks.com"


  def send_links(user_email , links, message)
  	@user_email = user_email 
  	@links = links 
  	@message = message

  	if not @links.empty?
		mail(to: @user_email, subject: "Some One sent you links using pinlinks")
	end
  end

end
