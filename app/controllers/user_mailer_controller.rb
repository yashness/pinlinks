class UserMailerController < ApplicationController

	def send_manual_links
		send_links = params[:send_links]
		receipients = params[:receipients]
		compose_message = params[:compose_message]

		receipients = receipients.chomp.split(",")
		send_links = send_links.chomp.split("\n")

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

		receipients = receipients.chomp.split(",")
		send_link_ids = send_link_ids.chomp.split(",")
		@links = []
		for link_id in send_link_ids
			x = Link.find_by_id(link_id)
			if not x.nil?
				@links << x
			end
		end

		for receipient in receipients
			UserMailer.send_pinlinks(receipient , @links , compose_message ).deliver
		end
	
	    respond_to do |format|
	        format.js
	    end

	end

end
