class TwilioController < ApplicationController
	skip_before_action :verify_authenticity_token

	def phone_number_lookup
		# invoke Twilio Client
		@client = Twilio::REST::Client.new(config.account_sid, config.auth_token)
		# phone number lookup
		phone_number_info = @client.lookups
		                      		.phone_numbers(params['Body'])
		                      		.fetch(add_ons: ['ekata_reverse_phone'])

		if !ekata_available_in_country(phone_number_info.add_ons['results']['ekata_reverse_phone'])
			response_body = "Sorry this service is not available in your country"
		elsif ekata_success(phone_number_info.add_ons['status'], phone_number_info.add_ons['results']['ekata_reverse_phone'])
			# pull data from response
			if phone_number_info.add_ons['results']['ekata_reverse_phone']['result']['warnings'].empty?
				response_body = "The phone number #{params['Body']} has no associated warning."
			else
				response.body = "The phone number #{params['Body']} has associated warning(s). Calling back may trigger additional fees."
			end
		else
			response.body = "An error occurred. We are sorry."
		end

		response =Twilio::TwiML::MessagingResponse.new 
		response.message do |r|
			r.body response_body
	    end

	    render xml: response.to_xml
	end

	def callback_sms
		# code your callback here
		render json: { message: "ok" }, status: :ok
	end

	private

	def ekata_available_in_country(ekata_reverse_phone)
		p ekata_reverse_phone
		ekata_reverse_phone && ekata_reverse_phone['status'] != "failed"
	end

	def ekata_success(success, ekata_reverse_phone)
		success == "successful" && ekata_reverse_phone && ekata_reverse_phone['status'] == "successful"
	end
end