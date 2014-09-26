class ContainersController < ApplicationController

  require 'docker'

  def index
    @containers = JSON.parse Docker.connection.get('/containers/json?all=1')
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured (#{e.message}). It seems your Docker is not running!"
  end

  def create
    id = params['id']
    name = id.split(":").first.split("/").last
    dc = Docker::Container.create('Image' => id, 'name' => name )
    flash[:success] = "Container created."
    redirect_to containers_index_path
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured (#{e.message}). Maybe a container with the same name exist already!?"
    redirect_to images_index_path
  end

  def start
    cid = params['id']
    image_name = image_name_for cid
    config = config_for image_name
    opt = config['container_start_opts']
    Docker.connection.post("/containers/#{cid}/start", nil, :body => opt.to_json)
    flash[:success] = "Container started."
    redirect_to containers_index_path
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured (#{e.message}). Delete the container and create a new one."
    redirect_to containers_index_path
  end

  def stop
    id = params['id']
    Docker.connection.post("/containers/#{id}/stop")
    flash[:success] = "Container stoped."
    redirect_to containers_index_path
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "Something went wrong (#{e.message}). It's time to use the Kill button!"
    redirect_to containers_index_path
  end

  def kill
    id = params['id']
    Docker.connection.post("/containers/#{id}/kill")
    flash[:success] = "Container killed."
    redirect_to containers_index_path
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "Your system is fucked up (#{e.message}). Contact one of the core comitters and be nice to him!"
    redirect_to containers_index_path
  end

  def delete
    id = params['id']
    Docker.connection.delete("/containers/#{id}")
    flash[:success] = "Container send to /dev/null (Nirvana)."
    redirect_to containers_index_path
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join "\n"
    flash[:error] = "An error occured. Maybe the container is still running?"
    redirect_to containers_index_path
  end

  private

    def image_name_for cid
      image_name = ""
      containers = JSON.parse Docker.connection.get('/containers/json?all=1')
      containers.each do |container|
        if container['Id'].to_s.eql?(cid.to_s)
          image_name = container['Image']
          break
        end
      end
      image_name
    end

end
