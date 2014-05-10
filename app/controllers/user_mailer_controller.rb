require 'subscribe_on_mail_chimp'
class UserMailerController < ApplicationController

	def send_manual_links
		send_links = params[:send_links]
		receipients = params[:receipients]
		compose_message = params[:compose_message]

		receipients = receipients.chomp.split(",") rescue []
		send_links = send_links.chomp.split("\n") rescue []

		for link in send_links
			link.strip!
		end
		for receipient in receipients
			UserMailer.send_manual_links(receipient , send_links , compose_message ).deliver
		end
	
	    respond_to do |format|
	        format.js
	    end

	end

	def send_pinlinks
		send_link_ids = params[:send_link_ids]
		receipients = params[:receipients]
		compose_message = params[:compose_message]

		receipients = receipients.chomp.split(",") rescue []
		send_link_ids = send_link_ids.chomp.split(",") rescue []
		@links = []
		@link_ids = []
		for link_id in send_link_ids
			x = Link.find_by_id(link_id)
			if not x.nil?
				@links << x
				@link_ids << x.id
			end
		end
		@link_ids = @link_ids.join(',')
		for receipient in receipients
			UserMailer.send_pinlinks(receipient , @links , compose_message ).deliver
		end
	
	    respond_to do |format|
	        format.js
	    end

	end

	def send_pinlink
		link_id = params[:send_link_id]
		receipients = params[:receipients]
		compose_message = params[:compose_message]
		
		receipients = receipients.chomp.split(",") rescue []
		@link = Link.find_by_id(link_id)
		if not @link.nil?
			for receipient in receipients
				UserMailer.send_pinlinks(receipient , [@link] , compose_message ).deliver
			end
		end
	    respond_to do |format|
	        format.js
	    end

	end



	def send_repolinks
		send_repo_ids = params[:send_repo_ids]
		receipients = params[:receipients]
		compose_message = params[:compose_message]

		receipients = receipients.chomp.split(",") rescue []
		send_repo_ids = send_repo_ids.chomp.split(",") rescue []
		@repos = []
		@repo_ids = []
		for repo_id in send_repo_ids
			x = Repo.find_by_id(repo_id)
			if not x.nil?
				@repos << x
				@repo_ids << x.id
			end
		end
		@repo_ids = @repo_ids.join(',')
		for receipient in receipients
			UserMailer.send_repolinks(receipient , @repos , compose_message ).deliver
		end
	    respond_to do |format|
	        format.js
	    end

	end

	def send_repolink
		repo_id = params[:send_repo_id]
		receipients = params[:receipients]
		compose_message = params[:compose_message]
		receipients = receipients.chomp.split(",") rescue []
		@repo = Repo.find_by_id(repo_id)
		if not @repo.nil?
			for receipient in receipients
				UserMailer.send_repolinks(receipient , [@repo] , compose_message ).deliver
			end
		end
	    respond_to do |format|
	        format.js
	    end

	end

	def subscribe_for_mailing
		profile_name = params[:profile_name]
		email = params[:email]
		if ((not profile_name.nil?) && (not email.nil?))
			Delayed::Job.enqueue(SubscribeOnMailChimp.new(email , profile_name))
		end
		respond_to do |format|
	        format.js
	    end
	end

end
