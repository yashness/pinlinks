# put before filter here
class ReposController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :destroy, :add_tag]

  def index
    list
  	render('list')
  end

  def list
    user_name = params[:user_name]
    if user_name.nil? && current_user.nil?
      return
    elsif not user_name.nil?
      @user = User.find_by_profile_name(user_name)
      if not @user.nil?
          @repos = @user.repos 
      else
        flash[:alert] = "Page Doesn't Exist."
        render file: 'public/404', status: 404, formats: [:html]
      end
    else
      @user = current_user
      @repos = current_user.repos
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
      render file: 'public/404', status: 404, formats: [:html]
    end

  end
  def new
 	@repo = Repo.new
  end

  def create
  	@repo = Repo.new(params[:repo])
  	repo_name = @repo.name 
    repo_name = repo_name.chomp.split(" ")
    repo_name = repo_name.join("_")  
    @repo.name = repo_name
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
    if current_user == repo.user
    	if not repo.nil?
    		links_ids = repo.links.pluck(:id)
    		repo.delete
    		Link.delete_all(:id => links_ids)
     		redirect_to("/")
    	else
    		#not a valid request
      		redirect_to("/")
    	end
    else
      flash[:alert] = "You cannot delete other's repo!"
      redirect_to :back
    end
  end

  def add_tag
    @tags = params[:tags]
    repo_id = params[:repo_id]
    @repo = Repo.find_by_id(repo_id)
    if @repo.tags.nil? || @repo.tags.empty?
      @repo.tags = @tags
    else
      @repo.tags += " " + @tags
    end
    @repo.save
    redirect_to :back    
  end
end

