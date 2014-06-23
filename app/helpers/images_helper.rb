module ImagesHelper


  def remote_images_hash
    response = fetch_response ENV['REMOTE_IMAGES']
    JSON.parse response.body
    # images = {}
    # images['reiz/memcached:1.0.0']     = {'container_start_opts' => {'PortBindings' => { '11211/tcp' => [{'HostPort' => '11211'}]}}, 'comments' => 'First version' }
    # images['reiz/mongodb:1.0.0']       = {'container_start_opts' => {'PortBindings' => { '27017/tcp' => [{'HostPort' => '27017'}]}, 'Binds' => ['/mnt/mongodb:/data']}, 'comments' => 'First version' }
    # images['reiz/elasticsearch:1.0.0'] = {'container_start_opts' => {'PortBindings' => { '9200/tcp'  => [{'HostPort' => '9200'}], '9300' => [{'HostPort' => '9200'}]}, 'Binds' => ['/mnt/elasticsearch:/data']}, 'comments' => 'First version' }

    # images
  end


  def fetch_response url
    uri  = URI.parse url
    http = Net::HTTP.new uri.host, uri.port
    if uri.port == 443
      curl_ca_bundle  = '/opt/local/share/curl/curl-ca-bundle.crt'
      ca_certificates = '/usr/lib/ssl/certs/ca-certificates.crt'
      http.use_ssl = true
      if File.exist?(curl_ca_bundle)
        http.ca_file = curl_ca_bundle
      elsif File.exist?(ca_certificates)
        http.ca_file = ca_certificates
      end
    end
    path  = uri.path
    query = uri.query
    http.get("#{path}?#{query}")
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace.join("\n")
    nil
  end


end
