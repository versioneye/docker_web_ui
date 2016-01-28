module ImagesHelper


  def remote_images_hash
    response = fetch_response ENV['REMOTE_IMAGES']
    JSON.parse response.body
  rescue => e
    Rails.logger.error e.message
    {}
  end


  def fetch_response url

    proxy_addr = ENV['PROXY_ADDR']
    proxy_port = ENV['PROXY_PORT']
    proxy_user = ENV['PROXY_USER']
    proxy_pass = ENV['PROXY_PASS']
    ssl_verify = ENV['SSL_VERIFY']

    uri  = URI.parse url
    http = nil

    if proxy_addr.to_s.empty?
      http = Net::HTTP.new uri.host, uri.port
    elsif !proxy_addr.to_s.empty? && !proxy_port.to_s.empty? && !proxy_user.to_s.empty? && !proxy_pass.to_s.empty?
      http = Net::HTTP.new uri.host, uri.port, proxy_addr, proxy_port.to_i, proxy_user, proxy_pass
    elsif !proxy_addr.to_s.empty? && !proxy_port.to_s.empty? && proxy_user.to_s.empty?
      http = Net::HTTP.new uri.host, uri.port, proxy_addr, proxy_port.to_i
    end

    if uri.port == 443
      http.use_ssl = true
      if ssl_verify && ( ssl_verify.to_s.eql?('none') || ssl_verify.to_s.eql?('false') )
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      curl_ca_bundle  = '/opt/local/share/curl/curl-ca-bundle.crt'
      ca_certificates = '/usr/lib/ssl/certs/ca-certificates.crt'
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
    iname = image_name.split(":").first
    config = ""
    images = remote_images_hash
    images.each do |key, value|
      if key.eql?( image_name )
        config = images[key]
        break
      end
      if key.match(/\A#{iname}/) != nil
        config = images[key]
        break
      end
    end
    config
  end

end
