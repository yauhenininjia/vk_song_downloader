require 'open-uri'

class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def index
    vk = VkontakteApi::Client.new current_user.token
    @songs = vk.audio.get
  end

  def download
    uri = URI params[:url]
    filename = "app/assets/audio/#{params[:filename]}.mp3"
    path = song_path_for_download(uri, filename)
    send_file path, disposition: 'attachment'
  end

  private

  def song_path_for_download(uri, filename)
    if File.exist? filename
      filename
    else
      file = File.new filename, 'wb'
      file.write Net::HTTP.get uri
      file.close
      file.path
    end
  end
end
