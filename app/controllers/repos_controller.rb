# put before filter here
require 'securerandom'
class ReposController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :destroy, :add_tag]

  def index
    list
    @random_string = SecureRandom.hex(3).chop
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
	@user = User.find_by_profile_name(user_name)
  @repo = Repo.where( :name => repo_name , :user_id => @user.id).first
  @is_user_same
  if not @repo.nil?
   	@links = @repo.links
    # repo is private and user looking at it is not current_user then, dont allow him
    if current_user != @user && @repo.is_private && @user != nil
        #redirect to error page
        render file: 'public/404', status: 404, formats: [:html]    
    end
    @is_user_same = false
    if current_user == @user 
       @is_user_same = true
    end
    repo_id = @repo.id if not @repo.nil? rescue 0
    current_user_id = current_user.id if not current_user.nil? rescue 0
  else
   	# redirect to error page
    render file: 'public/404', status: 404, formats: [:html]
  end
     

  end

  def show_nouser_repo
      repo_name = params[:repo_name]
      @repo = Repo.where( :name => repo_name ).first
      if((not @repo.nil?) && (@repo.user_id.nil?))
          @links = @repo.links
          # render(:partial => 'shared/show_nouser_repo', :locals => { :repo => @repo , :links => @links})
      else
          render file: 'public/404', status: 404, formats: [:html]
      end

  end



  def new
 	@repo = Repo.new
  end

  def create
  	@repo = Repo.new(params[:repo])
  	repo_name = @repo.name 
    repo_name = repo_name.gsub(/[^0-9a-z ]/i, '')
    repo_name = repo_name.chomp.split(" ")
    repo_name = repo_name.join("_")  
    @repo.name = repo_name

    if @repo.save
      #check how to show flash messages over here(in presence of ajax).
      respond_to do |format|
          format.js
      end
  	else
      # error_messages = @repo.errors.full_messages.join("\n")
      # flash[:alert] = "Repo couldn't be created because: \n #{error_messages}"
      #check how to show flash messages over here(in presence of ajax).
      render :nothing => true
  	end
  end

  def destroy
	@repo_id = params[:repo_id]
	repo = Repo.find_by_id(@repo_id)
    if not repo.nil?
    	links_ids = repo.links.pluck(:id)
    	repo.delete
    	Link.delete_all(:id => links_ids)
    	respond_to do |format|
          format.js
      end
    else
    	#not a valid request
      render :nothing => true
    end
  end

  def add_tags_update_name
    @tags = params[:tags]
    repo_id = params[:repo_id]
    new_name= params[:new_name]
    @repo = Repo.find_by_id(repo_id)

    if not @repo.nil?
      new_tags = @tags.chomp.split(" ") rescue []
      if !new_tags.nil? && !new_tags.empty? 
        repo_tags = @repo.tags.chomp.split(" ") rescue nil
        final_tags = repo_tags | new_tags
        @repo.tags = final_tags.join(" ") rescue ""
        @repo.save
      end
      new_name = new_name.gsub(/[^0-9a-z ]/i, '')
      new_name = new_name.chomp.split(" ")
      new_name = new_name.join("_")  
      @repo.name = new_name if not new_name.blank?
      if @repo.save
        # check how to show Flash messages in this case.
        # Flash message would be : Your Repo has been updated.
        respond_to do |format|
                format.js
        end
      else
        # Handle this case later, (When repo name already exists)
        # Ask whether, want to merge both repos or choos different name
        # Do further steps accordingly.
        render :nothing => true
      end
    else
      # check how to show Flash messages in this case.
      render :nothing => true
    end

  end


  def remove_tag
    tag_to_be_deleted = params[:tag]
    @repo_id = params[:repo_id]
    @repo = Repo.find_by_id(@repo_id)
    if not @repo.nil?
      tags = @repo.tags
      tags = tags.chomp.split(" ")
      if tags.include?(tag_to_be_deleted)
        tags.delete(tag_to_be_deleted)
        tags = tags.join(" ")
        @repo.tags = tags
        @repo.save
      end
      respond_to do |format|
          format.js
      end
    else
      # check how to show Flash messages in this case.
      redirect_to :back      
    end

  end


  # def fork
  #   if current_user.nil?
  #      flash[:alert] = "You need to be logged in, for forking!"         
  #      redirect_to "/"
  #   else
  #     repo = Repo.find_by_id(params[:repo_id].to_i)
  #     user = User.find_by_id(params[:user_id].to_i)
  #     successful_fork = true
  #     if user != nil? && repo != nil?
  #         forked_repo = Repo.new
  #         links = repo.links
  #         forked_repo.name = repo.name
  #         forked_repo.tags = repo.tags
  #         forked_repo.user_id = current_user.id
  #         if not forked_repo.save
  #           successful_fork = false
  #         end
  #         for link in links
  #           new_link = Link.new
  #           new_link.tags = link.tags
  #           new_link.actual_link = link.actual_link
  #           new_link.description = link.description
  #           new_link.repo_id = forked_repo.id
  #           if not new_link.save
  #             successful_fork = false
  #           end
  #         end
  #         if successful_fork
  #           flash[:alert] = "Successfully forked!"         
  #           user_fork = UserFork.new
  #           user_fork.user_id = current_user.id
  #           user_fork.repo_id = repo.id
  #           user_fork.save
  #           repo.fork_counts += 1
  #           repo.save 
  #         else
  #           flash[:alert] = "Un Successfull fork!"         
  #         end
  #         redirect_to("/#{user.profile_name}/#{repo.name}")
  #     else
  #           flash[:alert] = "Bad fork request! }"         
  #           redirect_to("/#{user.profile_name}/#{repo.name}")
  #     end
  #   end
  # end



  # def repo_search_results
  #   user_name = params[:user_name]
  #   if user_name.nil? && current_user.nil?
  #     return
  #   elsif not user_name.nil?
  #     @user = User.find_by_profile_name(user_name)
  #     if not @user.nil?
  #         logger.info @user.inspect
  #         user_id = @user.id
  #         @search = Repo.search do
  #           fulltext params[:search]
  #           with :user_id, user_id  
  #         end
  #         @repos = @search.results
  #     else
  #       flash[:alert] = "Page Doesn't Exist."
  #       render file: 'public/404', status: 404, formats: [:html]
  #     end
  #   else
  #     @user = current_user
  #     user_id = @user.id
  #     @search = Repo.search do
  #       fulltext params[:search]
  #       with :user_id, user_id 
  #     end
  #     @repos = @search.results
  #   end
  #   render('list')
  # end

end

