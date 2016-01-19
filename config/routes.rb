Rails.application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks" }
  get 'download' => 'songs#download'
  post 'download_zip' => 'songs#download_zip'
  root 'songs#index'
end
