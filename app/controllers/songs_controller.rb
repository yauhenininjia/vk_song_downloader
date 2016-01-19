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
    #songs = params[:songs]
    #songs.map { |song| JSON.parse song }.each do |song|
      #uri = URI song["url"]
      #filename = "app/assets/audio/#{song['filename']}.mp3"
      file = song_for_download(uri, filename)
      send_file file.path, disposition: 'attachment'
    #end
  end

  private

  def song_for_download(uri, filename)
    file = nil
    if File.exist? filename
      file = File.open filename
    else
      file = File.new filename, 'wb'
      file.write Net::HTTP.get uri
    end
    file
  end
end
