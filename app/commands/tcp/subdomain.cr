require "json"

class SubdomainCommand < TcpCommand
  def call
    unless client.authorized?
      send_error!(:unauthorized, "Authorization required")
      return
    end

    new_subdomain = command["subdomain"].as_s.gsub(/\s/, "") if command["subdomain"]?

    if new_subdomain.nil? || new_subdomain.size == 0
      info "SUBDOMAIN blank - return default one"
    elsif app && app.subdomains[new_subdomain]?
      info "SUBDOMAIN \"#{new_subdomain}\" NOT AVAILABLE"
    else
      client.register_subdomain Subdomain.new(client.uuid, new_subdomain)
    end

    respond!
  end

  def result?
    info "SUBDOMAIN !!!\"#{client.subdomain.try(&.namespace)}\"!!!"
    JSON.build do |json|
      json.object do
        json.field :command do
          json.object do
            json.field :kind, command["kind"]?.to_s
            json.field :subdomain, client.subdomain.try(&.namespace)
          end
        end
      end
    end
  end

  def respond!
    socket.puts result?
  end
end

Commands::Hub.register("subdomain", SubdomainCommand)
