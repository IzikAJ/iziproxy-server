class HTTP::Server::Context
  CLIENT_IP_HEADERS = %w(
    CLIENT_IP
    X_REAL_IP
    X_FORWARDED_FOR
    X_FORWARDED
    X_CLUSTER_CLIENT_IP
    FORWARDED
  )

  @remote_ip : String?

  def remote_ip
    @remote_ip ||= CLIENT_IP_HEADERS.map do |header|
      dashed_header = header.tr("_", "-")
      if headers = request.headers
        headers[header]? || headers[dashed_header]? || headers["HTTP_#{header}"]? || headers["Http-#{dashed_header}"]?
      end
    end.find { |ip| (ip.try(&.strip.size) || 0) > 0 }
  end
end
