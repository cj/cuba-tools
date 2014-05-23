module Cuba::Tools
  module Auth
    extend self

    attr_accessor :config

    def setup
      yield config
    end

    def config
      @config || reset_config
    end

    # Resets the configuration to the default (empty hash)
    def reset_config
      @config = OpenStruct.new({
        user_class: 'User'
      })
    end

    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        responder = Responder.new(@app, env)
        responder.respond
      end
    end

    class Responder
      def initialize(app, env)
        @app = app
        @env = env
      end

      def respond
        res.finish
      end

      private

      def path
        @env['REQUEST_PATH']
      end

      def req
        @req ||= Rack::Request.new(@env)
      end

      def res
        @res ||= begin
          status, headers, body = @app.call(req.env)
          Rack::Response.new(body, status, headers)
        end
      end
    end

    module Helpers
      def self.setup app
        if !defined? Devise
          require 'shield'
          app.plugin Shield::Helpers
          # app.use Shield::Middleware, "/login"
        else
          require 'warden'
          require 'devise'
          app.plugin Devise::TestHelpers
        end
      end

      def current_user
        @current_user ||= if !defined? Devise
          authenticated user_class
        else
          req.env['warden'].authenticate(scope: :user)
        end
      end

      def sign_in *args
        if args.length > 1
          user, scope = args
        else
          scope = :user
          user  = args.first
        end

        if !defined? Devise
          session.clear
          session[user_class.to_s] = user.id
        else
          @request = req
          super scope, user
        end
      end

      private

      def user_class
        Cuba::Tools::Auth.config.user_class.constantize
      end
    end
  end
end
