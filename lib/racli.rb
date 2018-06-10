require 'racli/version'
require 'racli/context'

module Racli
  class CLI
    def initialize
      content = File.read('./config.ru')
      file = '(racli)'
      @context = eval "::Racli::Context.new { #{content} }.to_app", TOPLEVEL_BINDING, file, 0
    end

    def call(args)
      status, headers, body = @context.call({
        'PATH_INFO' => '/hoge',
        'REQUEST_METHOD' => '',
        'QUERY_STRING' => 'aa=bb'
      })

      Racli.handlers.each do |handler|
        handler.call(status, headers, body)
      end
    end
  end

  class << self
    def handlers
      @handlers ||= Handlers.new
    end
  end

  class Handlers < Array
    alias :add :push
  end

  class DefaultHandler
    def call(status, headers, body)
      if status.to_s[0] == '2'
        puts body[0]
      else
        STDERR.puts body[0]
      end
    end
  end

  handlers.add DefaultHandler.new
end
