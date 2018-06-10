require 'racli/rack'
require 'cgi'
require 'json'

Dir['./lib/racli/handlers/**/*.rb'].each { |f| require f }

module Racli
  class CLI
    attr_accessor :method, :path, :params, :config

    def initialize(config:, rcfile:)
      config_ruby_string = File.read(config)
      @rackapp = eval "::Racli::Rack.new { #{config_ruby_string} }.to_app", TOPLEVEL_BINDING, '(racli)', 0
      @default_handler = Racli::Handlers::DefaultHandler.new(self)

      eval(File.read(rcfile)) if File.exists?(rcfile)
    end

    def call(method:, path:, params:)
      request_params = request_params(method: method, path: path, params: params)
      status, headers, body = @rackapp.call(request_params)

      original_args = { method: method, path: path, params: params }
      catch(:abort) do
        response_handlers = handlers + [@default_handler]
        response_handlers.reduce([status, headers, body]) do |(status, headers, body), handler|
          handler.call(status, headers, body, original_args)
        end
      end
    end

    def add_handler(handler_klass, index = 0)
      handler = handler_klass.new(self)
      handlers.insert index, handler
    end

    private

    def request_params(method:, path:, params:)
      query_string = to_query_string(params)
      request_params = {
        'PATH_INFO' => path || '/',
        'REQUEST_METHOD' => method || 'GET',
      }
      if method == 'GET'
        request_params['QUERY_STRING'] = query_string
        request_params['rack.input'] = StringIO.new('')
      else
        request_params['QUERY_STRING'] = ''
        request_params['rack.input'] = StringIO.new(query_string)
      end
      request_params
    end

    def handlers
      @handlers ||= []
    end

    def to_query_string(params)
      params.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')
    end
  end
end
