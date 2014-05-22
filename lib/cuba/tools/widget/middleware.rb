module Cuba::Tools
  module Widget
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        responder = Responder.new(@app, env)
        responder.respond
      end
    end
  end
end
