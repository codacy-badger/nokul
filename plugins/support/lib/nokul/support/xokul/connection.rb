# frozen_string_literal: true

module Xokul
  class Connection
    attr_accessor :endpoint

    def initialize(endpoint)
      @endpoint = endpoint
      # Actually, there are lots of default headers coming with Kong. Most param
      # is to manage Kong-specific configurations. Therefore, they won't be added
      # here. Instead that, common configurations suggested by community will be
      # set up at Kong side.
      @headers  = { 'Content-Type' => 'application/json' }
    end

    # Will be redesigned using dispatcher.
    def get(path, params: {})
      url  = URI.join(endpoint, path).to_s
      resp = Support::REST.get(url, headers: headers, payload: params.to_json, **ssl_opts)
      JSON.parse(resp.body) # Keep it here temporarily
    end

    def bearer_auth(bearer_token)
      headers['Authorization'] = "Bearer #{bearer_token}"
    end

    private

    attr_reader :headers

    def ssl_opts
      { use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_PEER }
    end
  end
end