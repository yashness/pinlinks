# put before filter here
class ReposController < ApplicationController

  def index
  	list
  	render('list')
  end
  def list
    if current_user.nil?
       user_name = params[:user_name]
       if user_name.nil?
          #SHOW FLASH ERROR (Wrong Request..PAGE DOESNT EXIST.)
          redirect_to "/error_page"
       else
            @user = User.find_by_profile_name(user_name)
            if not @user.nil?
                @repos = @user.repos 
                @repo = Repo.new
            else
              #SHOW FLASH ERROR (Wrong Request..PAGE DOESNT EXIST.)
              redirect_to "/error_page"
            end
       end
    else
        @user = current_user
      	@repos = current_user.repos 
        @repo = Repo.new
    end
  end

  def show
	user_name = params[:user_name]
	repo_name = params[:repo_name]
	user = User.find_by_profile_name(user_name)
  	@repo = Repo.where( :name => repo_name , :user_id => user.id).first
  	if not @repo.nil?
	  	@links = @repo.links
    else
    	# redirect to error page
      redirect_to "/error_page"
    end

  end
  def new
 	@repo = Repo.new
  end

  def create
  	@repo = Repo.new(params[:repo])
  	if @repo.save
      # display flash message with content (YOUR REPO has been created).
  		redirect_to("/")
  	else
      # display flash message with content (@repo.error_messages).
      redirect_to("/")
  	end
  end

  def destroy
	repo_id = params[:repo_id]
	repo = Repo.find_by_id(repo_id)
	if not repo.nil?
		links_ids = repo.links.pluck(:id)
		repo.delete
		Link.delete_all(:id => links_ids)
 		redirect_to("/")
	else
		#not a valid request
  		redirect_to("/")
	end

  end

end

