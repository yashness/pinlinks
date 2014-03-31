class LinksController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :destroy, :add_tag, :add_description]
  def index
  end

  def new
  	@repo_name = params[:repo_name] 
  end

  def create
  	all_links = params[:all_links]
  	repo_name = params[:repo_name]
    repo_name = repo_name.chomp.split(" ")
    repo_name = repo_name.join("_")  
  	if not repo_name.blank?
	  	all_links = all_links.chomp.split("\n")
		@repo = Repo.where( :name => repo_name , :user_id => current_user.id).first
		if not @repo.nil?
		  	repo_id = @repo.id
		  	for link in all_links
			  	@link = Link.new()
			  	@link.actual_link = link
			  	@link.repo_id = repo_id
			  	@link.save
		  	end
		  	if all_links.empty?
				flash[:alert] = "Please enter atlest one link!"
			else
				flash[:alert] = "Links added to existing repository!"
			end
		else
			#make a new repo with repo_name and add all_links in it
			@repo = Repo.new
			@repo.name = repo_name
			@repo.user_id = current_user.id
			@repo.save
		  	for link in all_links
			  	@link = Link.new()
			  	@link.actual_link = link
			  	@repo.links << @link
		  	end
			flash[:alert] = "New Repo sucessfully created!"
		end
	  		redirect_to("/#{current_user.profile_name}/#{repo_name}")
	else
			#flash message that reponame cant be blank
			flash[:alert] = "Repo-name cannot be blank!"
	  		redirect_to("/#{current_user.profile_name}/#{repo_name}")
	end
  end

  def destroy
  	repo_name = params[:repo_name]
  	repo = Repo.find_by_name(repo_name)
  	if not repo.nil?
	  	if current_user == repo.user
				link_id = params[:link_id]
				link = Link.find_by_id(link_id)
				if not link.nil?
					link.delete
					flash[:alert] = "Link successfully deleted!"
			 		redirect_to("/#{current_user.profile_name}/#{repo_name}")
				else
			  		redirect_to("/#{current_user.profile_name}/#{repo_name}")
				end
			else
				flash[:alert] = "You cannot delete others link!"
			end
		else
			flash[:alert] = "Invalid Request!"
		end
			redirect_to :back
  end

  def add_tag
    @tags = params[:tags]
    link_id = params[:link_id]
    @link = Link.find_by_id(link_id)
    if @link.tags.nil? || @link.tags.empty?
    	@link.tags = @tags
  	else
    	@link.tags += " " + @tags
    end
    @link.save
    redirect_to :back    
  end

  def add_description
    @desription = params[:description]
    link_id = params[:link_id]
    @link = Link.find_by_id(link_id)
    @link.description = @desription 
    @link.save
    redirect_to :back    
  end

end
