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
		send_links = params[:send_links]
		receipients = params[:receipients]
		compose_message = params[:compose_message]

		receipients = receipients.chomp.split(",")
		send_links = send_links.chomp.split("\n")
		@links = []
		for link in send_links
			x = Link.find_by_actual_link(link.strip)
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
