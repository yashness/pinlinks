class LinksController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :destroy]
  def index
  end

  def new
  	@repo_name = params[:repo_name] 
  end

  def create
  	all_links = params[:all_links]
  	repo_name = params[:repo_name]

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
	link_id = params[:link_id]
	link = Link.find_by_id(link_id)
	if not link.nil?
		link.delete
		flash[:alert] = "Link successfully deleted!"
 		redirect_to("/#{current_user.profile_name}/#{repo_name}")
	else
  		redirect_to("/#{current_user.profile_name}/#{repo_name}")
	end

  end




end
