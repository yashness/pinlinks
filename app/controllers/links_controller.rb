class LinksController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :destroy, :add_tag, :add_description]
  def index
  end

  def new
  	@repo_name = params[:repo_name] 
  end

  def create
  	all_links = params[:all_links]
  	is_private = params[:is_private]
  	repo_name = params[:repo_name]
    repo_name = repo_name.chomp.split(" ")
    repo_name = repo_name.join("_")  
  	if not repo_name.blank?
	  	all_links = all_links.chomp.split("\n")
		@repo = Repo.where( :name => repo_name , :user_id => current_user.id).first
		@saved_links = []
		if not @repo.nil?
		# Means the repo name already exists.
		# Ask User through modal form, whether he want to merge links in existing folder.
		# Or take a new name Or go ahead with auto suggested name
		# Handle all these cases later...
		  	repo_id = @repo.id
		  	for link in all_links
			  	@link = Link.new()
			  	@link.actual_link = link.strip
			  	@link.repo_id = repo_id
			  	@saved_links << @link if @link.save
		  	end
		  	if all_links.empty?
				#flash[:alert] = "Please enter atlest one link!"
		  		# Check how to show flash message here
			else
				#flash[:alert] = "Links added to existing repository!"
		  		# Check how to show flash message here
			end
		else
			#make a new repo with repo_name and add all_links in it
			@repo = Repo.new
			@repo.name = repo_name
			@repo.user_id = current_user.id
			if is_private == "1"
				@repo.is_private = true
			end
			@repo.save
		  	for link in all_links
			  	@link = Link.new()
			  	@link.actual_link = link
			  	@repo.links << @link
		  	end
			@saved_links = @repo.links
			#flash[:alert] = "New Repo sucessfully created!"
	  		# Check how to show flash message here
		end
		respond_to do |format|
        	format.js
      	end
	else
			#flash message that reponame cant be blank
			#flash[:alert] = "Repo-name cannot be blank!"
	  		# Check how to show flash message here
	  		redirect_to("/#{current_user.profile_name}/#{repo_name}")
	end
  end

  def create_without_user
  	all_links = params[:all_links]
  	all_links = all_links.chomp.split("\n")
  	repo_name = params[:repo_name]
    repo_name = repo_name.chomp.split(" ")
    repo_name = repo_name.join("_")  

    if not repo_name.blank?
    	@repo = Repo.new
		@repo.name = repo_name
		@repo.save
		for link in all_links
		  	@link = Link.new()
		  	@link.actual_link = link
		  	@repo.links << @link
		end
    end
    render :nothing => true
  end

  def destroy
  	repo_name = params[:repo_name]
  	repo = Repo.find_by_name(repo_name)
  	if not repo.nil?
	  	if current_user == repo.user
			link_id = params[:link_id]
			link = Link.find_by_id(link_id)
			if not link.nil?
				@link_id = link.id
				link.delete
				flash[:alert] = "Link successfully deleted!"
				respond_to do |format|
		          format.js
		      end
			else
				redirect_to("/#{current_user.profile_name}/#{repo_name}")
			end
		else
			flash[:alert] = "You cannot delete others link!"
			redirect_to :back
		end
	else 
		flash[:alert] = "Invalid Request!"
		redirect_to :back
	end
  end

  def add_tags_and_describe
    @tags = params[:tags]
    @desription = params[:description]
    link_id = params[:link_id]
    @link = Link.find_by_id(link_id)

    if not @link.nil?
	    new_tags = @tags.chomp.split(" ") rescue []
	    link_tags = @link.tags.chomp.split(" ") rescue nil
	    final_tags = link_tags | new_tags
	    @link.tags = final_tags.join(" ") rescue ""
	    @link.description = @desription 
	    @link.save
        respond_to do |format|
                format.js
        end
	end

  end

  def remove_tag
    tag_to_be_deleted = params[:tag]
    link_id = params[:link_id]
    @link = Link.find_by_id(link_id)
    if not @link.nil?
	    tags = @link.tags
	    tags = tags.chomp.split(" ")

	    if tags.include?(tag_to_be_deleted)
	      tags.delete(tag_to_be_deleted)
	      tags = tags.join(" ")
	      @link.tags = tags
	      @link.save
	    end
	    respond_to do |format|
          format.js
      end
	else
      # check how to show Flash messages in this case.
      redirect_to :back      
    end
  end

end
