require 'open-uri'

class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def index
    @vk = VkontakteApi::Client.new current_user.token
    @songs = @vk.audio.get
  end

  def download
    songs = params[:songs]
    songs.each do |song|
      song = JSON.parse song
      uri = URI song['url']
      filename = "#{song['filename']}.mp3"
      file = nil
      if File.exist? filename
        file = File.open filename
      else
        file = File.new filename, 'wb'
        file.write Net::HTTP.get uri
      end
      send_file file, disposition: 'attachment'
    end
    puts 'end'      
      
  end
end
