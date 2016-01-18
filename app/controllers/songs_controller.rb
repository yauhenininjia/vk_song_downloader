require 'open-uri'

class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  #after_action only: :download do
  #  delete_songs
  #end

  def index
    @vk = VkontakteApi::Client.new current_user.token
    @songs = @vk.audio.get
    #binding.pry
  end

  def download
    #binding.pry
    uri = URI params[:url]
    filename = "#{params[:filename]}.mp3"
    file = File.new filename, 'wb'
    file.write Net::HTTP.get uri
    send_file file
    puts 'data sent'
  end

  def delete_songs
    puts 'delete songs'
    #File.delete "#{params[:filename]}.mp3"
  end
end
