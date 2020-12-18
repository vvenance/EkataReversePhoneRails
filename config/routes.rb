Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  post '/phone-number-lookup', action: :phone_number_lookup, controller: 'twilio'
  post 'callback-sms', action: :callback_sms, controller: 'twilio'
end
