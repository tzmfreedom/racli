require 'optparse'

module Racli
  class OptionParser
    def call(args)
      options, args = parse(args)
      config_params = { config: options[:config], rcfile: options[:rcfile] }

      params = { method: 'GET', path: '/' }
      params[:method] = args[0] if args.length > 0
      params[:path] = args[1] if args.length > 1

      request_params = options.dup
      request_params.delete(:config)
      request_params.delete(:rcfile)
      params[:params] = request_params

      [config_params, params]
    end

    private

    def parse(args)
      keys = args.select { |key| key.include?('--') }
               .map { |key| key.gsub(/^\-\-/, '') }
               .reject { |key| ['config', 'rcfile'].include?(key) }
      options = {}
      options[:config] = File.expand_path('./config.ru', Dir.pwd)
      options[:rcfile] = File.expand_path('./.raclirc', Dir.pwd)

      parser = ::OptionParser.new
      parser.on('-c', '--config VALUE') { |v| options[:config] = v }
      parser.on('--rcfile VALUE') { |v| options[:rcfile] = v }
      keys.each do |key|
        parser.on("--#{key} VALUE") { |v| options[key.to_s] = v }
      end

      args = parser.parse(ARGV)
      [options, args]
    end
  end
end
