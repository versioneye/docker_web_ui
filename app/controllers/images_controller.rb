class ImagesController < ApplicationController

  require 'docker'

  def index
    @images = JSON.parse Docker.connection.get('/images/json')
    @r_images = remote_images_hash
  rescue => e
    Rails.logger.error e.message
    flash[:error] = "An error occured (#{e.message}). It seems your Docker is not running!"
  end

  def delete
    id = params['id']
    Docker.connection.delete("/images/#{id}")
    flash[:success] = "Image deleted."
    redirect_to images_index_path
  rescue => e
    Rails.logger.error e.message
    flash[:error] = "An error occured. Maybe a container of this image is still running?"
    redirect_to containers_index_path
  end

  def create
    id = params['id'] # reiz/mongodb:1.0.0
    sp = id.split(":")
    name = sp.first
    tag = sp.last
    trigger_download name, tag
    flash[:success] = "The download was triggered. This can take a couple minutes. Please refresh the page regulary."
    redirect_to images_index_path
  rescue => e
    Rails.logger.error e.message
    flash[:error] = "An error occured (#{e.message}). Maybe you are offline?"
    redirect_to images_index_path
  end

  private

    def trigger_download name, tag
      Thread.new{
        begin
          uri = "/images/create?fromImage=#{name}&tag=#{tag}"
          dc = Docker.connection.post( uri )
        rescue => e
          p "error for POST /images/create?fromImage=#{name}&tag=#{tag}"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join "\n"
        end
      }
    end

end
