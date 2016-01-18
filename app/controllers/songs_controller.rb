class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def index
    @vk = VkontakteApi::Client.new current_user.token
    session[:state] = Digest::MD5.hexdigest(rand.to_s)
    redirect_to VkontakteApi.authorization_url(scope: [:notify, :friends, :photos], state: session[:state])

  end
end
