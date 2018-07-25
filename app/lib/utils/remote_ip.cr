require "ipaddress"

class HTTP::Server::Context
  CLIENT_IP_HEADERS = %w(
    CLIENT_IP
    REAL_IP
    FORWARDED_FOR
    FORWARDED
    CLUSTER_CLIENT_IP
  )

  @remote_ip : String?

  def remote_ip
    if headers = request.headers
      @remote_ip ||= find_public_ip(fetch_all_ip_headers(headers))
    end
  end

  private def find_public_ip(ips = [] of String)
    ips.find do |item|
      if ip = item
        begin
          !IPAddress::IPv4.new(ip).private?
        rescue
          false
        end
      end
    end || "127.0.0.1"
  end

  private def fetch_all_ip_headers(headers)
    CLIENT_IP_HEADERS.map do |header|
      x_header = "X_#{header}"
      headers.get?(header).try(&.concat(headers.get?(x_header) || [] of String))
    end
      .flatten
      .map(&.try(&.strip))
      .select { |ip| ip && ip.size > 0 }
      .uniq
  end
end
