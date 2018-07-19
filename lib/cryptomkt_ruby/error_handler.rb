require 'faraday'

class ErrorHandler < Faraday::Response::Middleware
  CLIENT_ERROR_STATUSES = 400...600

  def on_complete(env)
    case env[:status]
    when 404
      raise Faraday::Error::ResourceNotFound, response_values(env)
    when 407
      # mimic the behavior that we get with proxy requests with HTTPS
      raise Faraday::Error::ConnectionFailed, %(407 "Proxy Authentication Required ")
    when CLIENT_ERROR_STATUSES
      raise GenericError, response_values(env)
    end
  end

  def response_values(env)
    { status: env.status, headers: env.response_headers, body: env.body }
  end
end

class GenericError < Faraday::Error::ClientError
  def initialize(exception = nil)
    super("the server responded with status #{exception[:status]}: #{exception[:body]}")
  end
end
