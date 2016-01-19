Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  get 'download' => 'songs#download'
  root 'songs#index'
end
