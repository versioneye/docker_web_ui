module ImagesHelper


  def remote_images_hash
    response = fetch_response ENV['REMOTE_IMAGES']
    JSON.parse response.body
  rescue => e
    Rails.logger.error e.message
    {}
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
