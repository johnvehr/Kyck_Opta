require 'resque/server'
KyckOpta::Application.routes.draw do
 
  resque_constraint = lambda do |request|
    request.env['warden'].authenticated? && request.env['warden'].user.admin?
  end

  constraints resque_constraint do
    mount Resque::Server.new, :at => "/resque"
  end

    get :show_raw_stat_really_secret_url, :to => 'opta#show_raw_stat'
  match '/opta/push_test/:id', :to => 'opta#push_test', :as => "opta_push_test"
  match '/opta/push_test_many', :to => 'opta#push_test_many', :as => "opta_push_test_many" 

  match '/opta/push', :to => 'opta#push'

end
