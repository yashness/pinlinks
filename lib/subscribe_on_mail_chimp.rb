class SubscribeOnMailChimp < Struct.new(:email , :profile_name)
	def perform
	    response = $mailchimp.lists.subscribe({
	      id: $registerd_user_list_id,
	      email: {email: email},
	      :merge_vars => {:FNAME => profile_name},
	      double_optin: false
	    })
	    puts "Subscribe For Mailing List Response:"
	    puts response
	end
end