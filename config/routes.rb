Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  post 'download' => 'songs#download'
  root 'songs#index'
end
