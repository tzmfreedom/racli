require 'racli/rack'
require 'cgi'
require 'json'

Dir[File.expand_path('./handlers/**/*.rb', __dir__)].each { |f| require f }

module Racli
  class CLI
    def initialize(config:, rcfile:)
      config_ruby_string = File.read(config)
      @rackapp = eval "::Racli::Rack.new { #{config_ruby_string} }.to_app", TOPLEVEL_BINDING, '(racli)', 0
      @default_handler = Racli::Handlers::DefaultHandler.new(self)
      @handlers = []
      @aliases = {}
      @default_headers = {}

      eval(File.read(rcfile)) if File.exists?(rcfile)
    end

    def call(method:, path:, params:, headers: @default_headers)
      if @aliases.include?(method.to_sym)
        alias_setting = @aliases[method.to_sym]
        method = alias_setting[:method]
        path = alias_setting[:path]
        headers.merge!(alias_setting[:headers])
      end

      request_params = request_params(method: method, path: path, params: params, headers: headers)
      status, headers, body = @rackapp.call(request_params)

      original_args = { method: method, path: path, params: params }
      catch(:abort) do
        response_handlers = @handlers + [@default_handler]
        response_handlers.reduce([status, headers, body]) do |(status, headers, body), handler|
          handler.call(status, headers, body, original_args)
        end
      end
    end

    def add_handler(handler_klass)
      handler = handler_klass.new(self)
      @handlers.push handler
    end

    def add_alias(alias_name, method = 'GET', path = '/', headers = {})
      @aliases[alias_name] = { method: method, path: path, headers: headers }
    end

    def default_headers(headers)
      @default_headers = headers
    end

    private

    def request_params(method:, path:, params:, headers:)
      query_string = to_query_string(params)
      request_params = {
        'PATH_INFO' => path || '/',
        'REQUEST_METHOD' => method || 'GET',
      }.merge(headers)

      if method == 'GET'
        request_params['QUERY_STRING'] = query_string
        request_params['rack.input'] = StringIO.new('')
      else
        request_params['QUERY_STRING'] = ''
        request_params['rack.input'] = StringIO.new(query_string)
      end
      request_params
    end

    def to_query_string(params)
      params.map { |k, v| "#{k}=#{CGI.escape(v)}" }.join('&')
    end
  end
end
