class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def index
    @vk = VkontakteApi::Client.new current_user.token
  end
end
