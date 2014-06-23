class ContainersController < ApplicationController

  require 'docker'

  def index
    @containers = JSON.parse Docker.connection.get('/containers/json?all=1')
  end

  def create
    id = params['id']
    name = id.split(":").first.split("/").last
    dc = Docker::Container.create('Image' => id, 'name' => name )
    flash[:sucess] = "Container created."
    redirect_to containers_index_path
  end

  def start
    cid = params['id']
    opt = {'PortBindings' => { "11211/tcp" => [{"HostPort" => "11211"}] } } # TODO
    Docker.connection.post("/containers/#{cid}/start", nil, :body => opt.to_json)
    flash[:sucess] = "Container started."
    redirect_to containers_index_path
  end

  def stop
    id = params['id']
    Docker.connection.post("/containers/#{id}/stop")
    flash[:sucess] = "Container stoped."
    redirect_to containers_index_path
  end

  def kill
    id = params['id']
    Docker.connection.post("/containers/#{id}/kill")
    flash[:sucess] = "Container killed."
    redirect_to containers_index_path
  end

  def delete
    id = params['id']
    begin
      Docker.connection.delete("/containers/#{id}")
      flash[:sucess] = "Container deleted."
    rescue => e
      Rails.logger.error e.message
      flash[:error] = "An error occured. Maybe the container is still running?"
    end
    redirect_to containers_index_path
  end

end
