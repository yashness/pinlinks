class UserMailer < ActionMailer::Base
  default from: "admin@pinlinks.com"


  #links should be array of Link objects
  def send_pinlinks(user_email , links, message)
  	@user_email = user_email 
  	@links = links 
  	@message = message

  	if not @links.empty?
		mail(to: @user_email, subject: "Some One sent you links using pinlinks")
	  end

  end

  #links should be array of strings
  def send_manual_links(user_email , links, message)
  	@user_email = user_email 
  	@links = links 
  	@message = message

  	if not @links.empty?
		mail(to: @user_email, subject: "Some One sent you links using pinlinks")
  	end
  end

  def send_repolinks(user_email , repos, message)
    @user_email = user_email 
    @repos = repos
    @message = message

    if not @repos.empty?
      mail(to: @user_email, subject: "Some One sent you links using pinlinks")
    end

  end

end
