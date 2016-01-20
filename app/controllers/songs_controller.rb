require 'open-uri'
require 'zip'
require 'will_paginate/array'

class SongsController < ApplicationController
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  after_action only: :download_zip do
    logger.info "Start deleting zip #{@zipfile_path}"
    File.delete(@zipfile_path)
    logger.info "Finish deleting zip #{@zipfile_path}"
  end

  def index
    vk = VkontakteApi::Client.new current_user.token
    @songs = vk.audio.get
    @songs = @songs.paginate(page: params[:page], per_page: 10)
  end

  def download_zip
    zip_tmp_file = Tempfile.new [current_user.uid, '.zip']
    @zipfile_path = zip_tmp_file.path

    songs = params[:songs]
    @files = []
    songs.map { |song| JSON.parse song }.each do |song|
      @files << {mp3_filename: mp3_filename("#{song['artist']} - #{song['title']}"),
        url: song['url'], artist: song['artist'], title: song['title']}
    end
    create_zip(@zipfile_path, @files)
    
    logger.info "Start sending #{@zipfile_path} to #{current_user.first_name} #{current_user.last_name}"
    File.open(@zipfile_path, 'r') { |f| send_data f.read, filename: 'vk_audio.zip' }
    logger.info "Finish sending #{@zipfile_path} to #{current_user.first_name} #{current_user.last_name}"
  end

  def download
    uri = URI params[:url]
    filename = mp3_filename(params[:filename])
    song_tmp_file = download_song_locally(params[:url], filename)
    logger.info "Start sending #{filename} to #{current_user.first_name} #{current_user.last_name}"
    #send_data open(params[:url]).read, filename: filename
    send_data song_tmp_file.read, filename: filename
    logger.info "Finish sending #{filename} to #{current_user.first_name} #{current_user.last_name}"
  end

  private

  def create_zip(zipfile_path, files)
    logger.info "Start creating zip in #{zipfile_path}"

    Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        name = file[:mp3_filename]
        uri = URI(file[:url])
        #song_tmp_file = open(file[:url])
        song_tmp_file = download_song_locally(file[:url], name)

        zipfile.add(name, song_tmp_file)
      end
    end
    logger.info "Finish creating zip in #{zipfile_path}"
  end

  def mp3_filename(name)
    "#{name}.mp3"
  end

  def download_song_locally(url, filename = 'noname')
    logger.info "Start downloading #{filename} from #{url}"
    tmp_file = open(url)
    logger.info "Finish downloading #{filename} from #{url}"
    tmp_file
  end
end
