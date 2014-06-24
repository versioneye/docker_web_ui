class ImagesController < ApplicationController

  require 'docker'

  def index
    @images = JSON.parse Docker.connection.get('/images/json')
    @r_images = remote_images_hash
  end

  def delete
    id = params['id']
    Docker.connection.delete("/images/#{id}")
    flash[:success] = "Image deleted."
    redirect_to images_index_path
  end

  def create
    id = params['id'] # reiz/mongodb:1.0.0
    sp = id.split(":")
    name = sp.first
    tag = sp.last
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
    flash[:success] = "The download was triggered. This can take a couple minutes. Please refresh the page regulary."
    redirect_to images_index_path
  end

end
