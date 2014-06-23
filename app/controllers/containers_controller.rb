class ContainersController < ApplicationController

  require 'docker'

  def index
    @containers = JSON.parse Docker.connection.get('/containers/json?all=1')
  end

  def create
    id = params['id']
    name = id.split(":").first.split("/").last
    dc = Docker::Container.create('Image' => id, 'name' => name )
    flash[:success] = "Container created."
    redirect_to containers_index_path
  end

  def start
    cid = params['id']
    image_name = image_name_for cid
    config = config_for image_name
    opt = config['container_start_opts']
    Docker.connection.post("/containers/#{cid}/start", nil, :body => opt.to_json)
    flash[:success] = "Container started."
    redirect_to containers_index_path
  end

  def stop
    id = params['id']
    Docker.connection.post("/containers/#{id}/stop")
    flash[:success] = "Container stoped."
    redirect_to containers_index_path
  end

  def kill
    id = params['id']
    Docker.connection.post("/containers/#{id}/kill")
    flash[:success] = "Container killed."
    redirect_to containers_index_path
  end

  def delete
    id = params['id']
    begin
      Docker.connection.delete("/containers/#{id}")
      flash[:success] = "Container deleted."
    rescue => e
      Rails.logger.error e.message
      flash[:error] = "An error occured. Maybe the container is still running?"
    end
    redirect_to containers_index_path
  end

  private

    def image_name_for id
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

    def config_for image_name
      config = ""
      images = remote_images_hash
      images.each do |key, value|
        if key.eql?( image_name )
          config = images[key]
        end
      end
      config
    end

end
