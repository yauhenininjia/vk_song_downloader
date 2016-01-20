require 'open-uri'
require 'zip'
require 'dropbox_sdk'

class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  after_action only: :download_zip do
    delete_songs(@files)
    logger.info "Started deleting zip #{@zipfile_path}"
    File.delete(@zipfile_path)
    logger.info "Finish deleting zip #{@zipfile_path}"
  end

  def per_page
    5
  end

  def index
    vk = VkontakteApi::Client.new current_user.token
    @songs = vk.audio.get[0...5]

    client = DropboxClient.new 'XMvuom9l0IAAAAAAAAAADscnpCK0BtjpulmwgmJHun7asGHSSoVDL12dBzwSQ3e5'

    if params[:page]
      @page = Integer params[:page]
    else
      @page = 0
    end
=begin
    @songs = vk.audio.get[@page * per_page...@page * per_page + per_page]

    respond_to do |format|
      format.html
      format.js
    end
=end
  end

  def download_zip
    @zipfile_path = "app/assets/audio/#{current_user.uid}.zip"

    songs = params[:songs]
    @files = []
    songs.map { |song| JSON.parse song }.each do |song|
      @files << {mp3_filename: mp3_filename("#{song['artist']} - #{song['title']}"),
        url: song['url'], artist: song['artist'], title: song['title']}
    end
    create_zip(@zipfile_path, @files)
    
    File.open(@zipfile_path, 'r') do |f|
      send_data f.read, filename: 'vk_audio.zip'
    end
  end

  def download
    uri = URI params[:url]
    filename = mp3_filename(params[:filename])
    #path = song_path_for_send(uri, filename)
    #set_song_info path, params[:artist], params[:title]
    
    #File.open(path, 'r') do |f|
      #send_data f.read, filename: filename
    #end
    #File.delete path

    send_data open(params[:url]).read, filename: filename
  end

  private

  def delete_songs(files)
    logger.info "Started deleting songs"
    files.each do |file|
      path = song_path(file[:mp3_filename])
      File.delete path if File.exist? path
      logger.info "Delete song #{path}"
    end
    logger.info "Finish deleting songs"
  end

  def create_zip(zipfile_path, files)
    logger.info "Creating zip in #{zipfile_path}"
    File.delete zipfile_path if File.exist? zipfile_path
    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        name = file[:mp3_filename]
        uri = URI(file[:url])
        download_song_locally(uri, song_path(name)) unless File.exist? song_path(name)
        set_song_info(song_path(name), file[:artist], file[:title])

        zipfile.add(name, song_path(name))
      end
    end
    logger.info "Finish creating zip in #{zipfile_path}"
  end

  def set_song_info(song_path, artist, title)
      Mp3Info.open song_path, encoding: 'utf-8' do |mp3|
        mp3.tag.artist = artist
        mp3.tag.title = title
      end
  end

  def song_path(name)
    "app/assets/audio/#{name}"
  end

  def mp3_filename(name)
    "#{name}.mp3"
  end

  def song_path_for_send(uri, filename)
    path = "app/assets/audio/#{filename}"
    unless File.exist?(path)
      download_song_locally(uri, path)
    end
    path
  end

  def download_song_locally(uri, path)
    logger.info "Start downloading to #{path}"
    file = File.new path, 'wb'
    file.write Net::HTTP.get uri
    file.close
    logger.info "Finish downloading to #{path}"
  end
end
