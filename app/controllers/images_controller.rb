class ImagesController < ApplicationController

  require 'docker'

  def index
    @images = JSON.parse Docker.connection.get('/images/json')
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured (#{e.message}). It seems your Docker is not running!"
  end

  def remote_images
    @r_images = remote_images_hash
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured (#{e.message}). It seems your Docker is not running!"
  end

  def delete
    id = params['id']
    Docker.connection.delete("/images/#{id}")
    flash[:success] = "Image deleted."
    redirect_to images_index_path
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
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
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured (#{e.message}). Maybe you are offline?"
    redirect_to images_index_path
  end

  private

    def trigger_download name, tag
      Thread.new{
        begin
          uri    = "/images/create?fromImage=#{name}&tag=#{tag}"
          config = config_for "#{name}:#{tag}"
          auth   = config['auth']
          dc = nil
          if auth == true
            user     = ENV['DOCKER_USER']
            password = ENV['DOCKER_PASSWORD']
            email    = ENV['DOCKER_EMAIL']
            options = {"username"=> user, "password"=> password, "email"=> email}
            creds = options.to_json
            headers = Docker::Util.build_auth_header(creds)
            dc = Docker.connection.post( uri, {}, :headers => headers )
          else
            dc = Docker.connection.post( uri )
          end
          Rails.logger.info "Done with #{name}. - #{dc.to_s}"
        rescue => e
          p "error for POST /images/create?fromImage=#{name}&tag=#{tag}"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join "\n"
        end
      }
    end

end
