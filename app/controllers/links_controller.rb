class LinksController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]
  def index
  end

  def new
  	@repo_name = params[:repo_name] 
  end

  def create
  	all_links = params[:all_links]
  	is_private = params[:is_private]
  	repo_name = params[:repo_name]
  	if not repo_name.blank?
	  	all_links = all_links.chomp.split("\n")
		@repo = Repo.where( :name => repo_name , :user_id => current_user.id).first
		@saved_links = []
		@append_repo_record = true
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
		  	@append_repo_record = false 
		    @flash_type = "success"
		    @flash_message = "Successfully dropped your links"
			respond_to do |format|
		       	format.js
		    end
		else
			#make a new repo with repo_name and add all_links in it
			@repo = Repo.new
			repo_name = repo_name.gsub(/[^0-9a-z ]/i, '')
    		repo_name = repo_name.chomp.split(" ")
		    repo_name = repo_name.join("_")  
			@repo.name = repo_name
			@repo.user_id = current_user.id
			@repo.is_private = true if is_private == "1"			
			if @repo.save
			  	for link in all_links
				  	@link = Link.new()
				  	@link.actual_link = link
				  	@repo.links << @link
			  	end
				@saved_links = @repo.links
				#flash[:alert] = "New Repo sucessfully created!"
			    @flash_type = "success"
			    @flash_message = "Successfully dropped your links"
				respond_to do |format|
		        	format.js
		      	end
	    	else
		      	# @flash_message = "Repo couldn't be created of invalid repo name."
		        render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>Links could not be dropped because of Invalid Repo Name!</div>')"
	    	end
		end

	else
      	# @flash_message = "Repo name cant be blank."
        render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>Make sure that your repo name cannot be blank</div>')"

	end
  end

  def create_without_user
  	all_links = params[:all_links]
  	all_links = all_links.chomp.split("\n")
  	repo_name = params[:repo_name]
  	repo_name = repo_name.gsub(/[^0-9a-z ]/i, '')
    repo_name = repo_name.chomp.split(" ")
    repo_name = repo_name.join("_")  
    @from_home = params[:from_home]
    @saved_links = []
    @repo = Repo.where( :name => repo_name).first

    if @repo.nil?
	   	@repo = Repo.new
		@repo.name = repo_name
		@repo.save
		for link in all_links
		  	@link = Link.new()
		  	@link.actual_link = link.strip
		  	@link.repo_id = @repo.id rescue nil
		  	@saved_links << @link if @link.save
		end

        session[:repo_names] ||= ""
        session_repos = session[:repo_names].split(",")
        session_repos << repo_name
        session[:repo_names] = session_repos.uniq.join(",")
    else
		for link in all_links
		  	@link = Link.new()
		  	@link.actual_link = link.strip
		  	@link.repo_id = @repo.id 
		  	@saved_links << @link if @link.save
		end
    end
	@flash_type = "success"
    @flash_message = "Successfully dropped your links."
	respond_to do |format|
       	format.js
    end
  end

  def forget_session_repos
  	  @from_home = params[:from_home] 
      session[:repo_names] = ""
	  @flash_type = "success"
	  @flash_message = "Forgetting session repos successfull."
	  respond_to do |format|
	   	format.js
	  end
  end



  def destroy
  	repo_name = params[:repo_name]
  	repo = Repo.find_by_name(repo_name)
  	session_repo_names = session[:repo_names] rescue ""
  	if not repo.nil?
  		# check if repo belongs to current_user or the non-platform user has just created
  		# it (ie. it would be in his session , hence he should be allowed to destroy link.)
	  	if (current_user == repo.user ) || (session_repo_names.include?(repo_name))
			link_id = params[:link_id]
			@link = Link.find_by_id(link_id)
			if not @link.nil?
				@link_id = @link.id
				@link.delete
				@flash_type = "success"
			    @flash_message = "Link deleted successfully."
				respond_to do |format|
			       	format.js
			    end
			else
		     	@flash_message = "Link doesn't exit. Bad Request."
		      	render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>#{@flash_message}</div>')"
			end
		else
	     	@flash_message = "You cannot operate on the repos not in your session or not belonging to you. Sorry."
	      	render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>#{@flash_message}</div>')"

		end
	else 
     	# @flash_message = "Invalid Request. No such repo exist!"
        render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>Link could not be destroyed bescause of Invalid Repo Name!</div>')"
	end
  end

  def destroy_all_links
  	repo_name = params[:repo_name]
  	repo = Repo.find_by_name(repo_name)
  	session_repo_names = session[:repo_names] rescue ""
  	@link_ids
  	if not repo.nil?
  		# check if repo belongs to current_user or the non-platform user has just created
  		# it (ie. it would be in his session , hence he should be allowed to destroy link.)
	  	links = repo.links
	  	@link_ids = links.pluck(:id)
	  	if (current_user == repo.user ) || session_repo_names.include?(repo_name)
			links.delete_all
			@flash_type = "success"
	     	@flash_message = "Successfully, destroyed all your links, in this repo."
			respond_to do |format|
	          format.js
	        end
	    end
	else 
     	# @flash_message = "Invalid Request. No such repo exist!"
	    render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>Links could not be destroyed because of Invalid Repo Name!</div>')"
	end
  end

  def add_tags_and_describe
    @tags = params[:tags]
    @desription = params[:description]
    link_id = params[:link_id]
    @link = Link.find_by_id(link_id)
    repo = @link.repo rescue nil
    owner_user = repo.user rescue nil
    session_repo_names = session[:repo_names] rescue ""
    if not @link.nil?
    	#check if owner of the link is same as current user... (Not owner can be nil if its as no-user repo's link)
    	# Or session contains the repo_name (ie its a non-user link and user on browser has created it.)
	    if (((current_user == owner_user) && (not owner_user.nil?)) || (session_repo_names.include?(repo.name)) )
		    new_tags = @tags.chomp.split(" ") rescue []
		    link_tags = @link.tags.chomp.split(" ") rescue []
		    final_tags = link_tags | new_tags
		    @link.tags = final_tags.join(" ") rescue ""
		    @link.description = @desription 
		    @link.save
			@flash_type = "success"
	     	@flash_message = "Successfully, updated your link."
	        respond_to do |format|
	                format.js
	        end
	    else
	     	@flash_message = "You cannot operate on the links not in your session or not belonging to you. Sorry."
	      	render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>#{@flash_message}</div>')"

	    end
	else
     	# @flash_message = "Invalid Request. No such link exist!"
        render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>Link could not be updated because of Invalid Link!</div>')"
	end

  end

  def remove_tag
    tag_to_be_deleted = params[:tag]
    link_id = params[:link_id]
    @link = Link.find_by_id(link_id)
    repo = @link.repo rescue nil
    owner_user = repo.user rescue nil
    session[:repo_names] ||= ""
    session_repo_names = session[:repo_names]
    if not @link.nil?
	    if (((current_user == owner_user) && (not owner_user.nil?)) || (session_repo_names.include?(repo.name)) )
			    tags = @link.tags
			    tags = tags.chomp.split(" ")
			    if tags.include?(tag_to_be_deleted)
			      tags.delete(tag_to_be_deleted)
			      tags = tags.join(" ")
			      @link.tags = tags
			      @link.save
			    end
				@flash_type = "success"
     			@flash_message = "Successfully removed the link tag."
			    respond_to do |format|
		          format.js
		        end
		else
	     	@flash_message = "You cannot operate on the links not in your session or not belonging to you. Sorry."
	      	render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>#{@flash_message}</div>')"
		end
	else
     	# @flash_message = "Invalid Request. No such link exist!"
	    render :js => "$('.ajax_flash').html('<div class=\"alert alert-warning alert-dismissable\"><button type=\"button\" class=\"close\" data-dismiss=\"alert\" aria-hidden=\"true\">&times;</button>Link tags could not be removed because of Invalid Link!</div>')"
    end

  end

end
