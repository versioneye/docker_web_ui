class ContainersController < ApplicationController

  require 'docker'

  def index
    @containers = JSON.parse Docker.connection.get('/containers/json?all=1')
  end

  def create
    id = params['id']
    name = id.split(":").first.split("/").last
    dc = Docker::Container.create('Image' => id, 'name' => name )
    redirect_to containers_index_path
  end

  def start
    cid = params['id']
    opt = {'PortBindings' => { "11211/tcp" => [{"HostPort" => "11211"}] } }
    Docker.connection.post("/containers/#{cid}/start", nil, :body => opt.to_json)
    redirect_to containers_index_path
  end

  def stop
    id = params['id']
    Docker.connection.post("/containers/#{id}/stop")
    redirect_to containers_index_path
  end

  def kill
    id = params['id']
    Docker.connection.post("/containers/#{id}/kill")
    redirect_to containers_index_path
  end

  def delete
    id = params['id']
    Docker.connection.delete("/containers/#{id}")
    redirect_to containers_index_path
  end

end
