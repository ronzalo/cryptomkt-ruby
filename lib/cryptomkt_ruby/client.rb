require 'faraday'
require 'openssl'
require 'json'
require_relative 'error_handler'

API_URL = 'https://api.cryptomkt.com'.freeze

module CryptomktRuby
  class Client
    def initialize(key, secret, options = {})
      @key = key
      @secret = secret
      @logger = options.delete(:logger)
    end

    def book(market:, type:, page: 1, limit: 20)
      path = '/v1/book'

      params = {
        market: market,
        type: type,
        page: page,
        limit: limit
      }

      public_get(path, params)
    end

    def trades(market:, start_at: Time.now, end_at: Time.now, page: 1, limit: 20)
      path = '/v1/trades'

      params = {
        market: market,
        start: start_at.strftime('%Y-%m-%d'),
        end: end_at.strftime('%Y-%m-%d'),
        page: page,
        limit: limit
      }

      public_get(path, params)
    end

    def market
      path = '/v1/market'

      public_get(path, {})
    end

    def ticker(market: nil)
      path = '/v1/ticker'

      public_get(path, market: market)
    end

    def active_orders(market:, page: 0, limit: 20)
      path = '/v1/orders/active'

      params = {
        market: market,
        page: page,
        limit: limit
      }

      private_get(path, params)
    end

    def executed_orders(market:, page: 0, limit: 20)
      path = '/v1/orders/executed'

      params = {
        market: market,
        page: page,
        limit: limit
      }

      private_get(path, params)
    end

    def cancel_order(id)
      path = '/v1/orders/cancel'

      private_post(path, id: id)
    end

    def status_order(id)
      path = '/v1/orders/status'

      private_get(path, id: id)
    end

    def instant_order(market:, type:, amount:)
      path = '/v1/orders/instant/get'

      params = {
        market: market,
        type: type,
        amount: amount
      }

      private_get(path, params)
    end

    def create_market_order(market:, type:, amount:, price:)
      path = '/v1/orders/create'

      params = {
        market: market,
        type: type,
        amount: amount,
        price: price
      }

      private_post(path, params)
    end

    def create_instant_order(market:, type:, amount:)
      path = '/v1/orders/instant/create'

      params = {
        market: market,
        type: type,
        amount: amount
      }

      private_post(path, params)
    end

    def balance
      path = '/v1/balance'

      private_get(path)
    end

    private

    def conn
      @conn ||= Faraday.new(url: API_URL) do |faraday|
        faraday.use ErrorHandler
        faraday.response :logger if @logger
        faraday.adapter  Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def parsed_response(response)
      json = JSON.parse(response.body)
      json['data']
    end

    def public_get(path, params)
      response = conn.get path, params

      parsed_response(response)
    end

    def private_get(path, params = {})
      timestamp = Time.now.to_i.to_s
      response = conn.get path, params do |req|
        req.headers['X-MKT-APIKEY'] = @key
        req.headers['X-MKT-SIGNATURE'] = signature(timestamp, path)
        req.headers['X-MKT-TIMESTAMP'] = timestamp
      end

      parsed_response(response)
    end

    def private_post(path, params = {})
      timestamp = Time.now.to_i.to_s
      response = conn.post path, URI.encode_www_form(params) do |req|
        req.headers['X-MKT-APIKEY'] = @key
        req.headers['X-MKT-SIGNATURE'] = signature(timestamp, path, params)
        req.headers['X-MKT-TIMESTAMP'] = timestamp
      end

      parsed_response(response)
    end

    def signature(timestamp, path, body = '')
      body = body.sort.to_h.values.reduce(:+) if body.is_a? Hash

      message = [timestamp, path, body].inject(:+)
      OpenSSL::HMAC.hexdigest('SHA384', @secret, message)
    end
  end
end
