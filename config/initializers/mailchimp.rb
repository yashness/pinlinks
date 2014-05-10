$registerd_user_list_id = '97023ebfde'
Gibbon::API.api_key = "029e5445db91c930b1f04e09f7c16e3c-us8"
Gibbon::API.timeout = 15
Gibbon::API.throws_exceptions = false
Rails.configuration.mailchimp = Gibbon::API.new()
$mailchimp = Rails.configuration.mailchimp