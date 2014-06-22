class ImagesController < ApplicationController

  require 'docker'

  def index
    @images = JSON.parse Docker.connection.get('/images/json')
    @r_images = remote_images_hash
  end

  def delete
    id = params['id']
    Docker.connection.delete("/images/#{id}")
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
        p "POST #{uri}"
        dc = Docker.connection.post( uri )
      rescue => e
        p "error for POST /images/create?fromImage=#{name}&tag=#{tag}"
        p e.message
        p e.backtrace.join "\n"
      end
    }
    # TODO Message to user
    redirect_to images_index_path
  end

  def remote_images
    images = remote_images_hash
    respond_to do |format|
      format.json {
        render :json => images.to_json
      }
      formmat.html {
        @r_images = images
      }
    end
  end

  private

    def remote_images_hash
      images = {}
      images['reiz/memcached:1.0.0']     = {'container_start_opts' => {'PortBindings' => { '11211/tcp' => [{'HostPort' => '11211'}]}}, 'comments' => 'First version' }
      images['reiz/mongodb:1.0.0']       = {'container_start_opts' => {'PortBindings' => { '27017/tcp' => [{'HostPort' => '27017'}]}, 'Binds' => ['/mnt/mongodb:/data']}, 'comments' => 'First version' }
      images['reiz/elasticsearch:1.0.0'] = {'container_start_opts' => {'PortBindings' => { '9200/tcp'  => [{'HostPort' => '9200'}], '9300' => [{'HostPort' => '9200'}]}, 'Binds' => ['/mnt/elasticsearch:/data']}, 'comments' => 'First version' }
      images
    end

    def fetch_response url
      uri  = URI.parse url
      http = Net::HTTP.new uri.host, uri.port
      path  = uri.path
      query = uri.query
      http.get("#{path}?#{query}")
    rescue => e
      p e.message
      p e.backtrace.join("\n")
      nil
    end

end
