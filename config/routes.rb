RubygemsStatus::Application.routes.draw do
  root :to => 'status#show'
  get 'status' => 'status#show'
end