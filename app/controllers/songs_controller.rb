require 'open-uri'
require 'zip'

class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  after_action only: :download_zip do
    delete_songs(@files)
    logger.info "Started deleting zip #{@zipfile_path}"
    File.delete(@zipfile_path)
    logger.info "Finish deleting zip #{@zipfile_path}"
  end

  def index
    vk = VkontakteApi::Client.new current_user.token
    @songs = vk.audio.get
  end

  def download_zip
    @zipfile_path = "app/assets/audio/#{current_user.uid}.zip"

    songs = params[:songs]
    @files = []
    songs.map { |song| JSON.parse song }.each do |song|
      @files << {mp3_filename: mp3_filename(song['filename']), url: song['url']}
    end
    create_zip(@zipfile_path, @files)
    
    File.open(@zipfile_path, 'r') do |f|
      send_data f.read, filename: 'vk_audio.zip'
    end
  end

  def download
    uri = URI params[:url]
    filename = mp3_filename(params[:filename])
    path = song_path_for_send(uri, filename)
    
    send_file path
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
        zipfile.add(name, song_path(name))
      end
    end
    logger.info "Finish creating zip in #{zipfile_path}"
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
