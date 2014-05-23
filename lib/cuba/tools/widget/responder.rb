module Cuba::Tools
  module Widget
    class Responder
      def initialize(app, env)
        @app = app
        @env = env
      end

      def respond
        if widget_path
          widget_name, widget_event, events = Widget.load_all @app, req, res

          events.trigger widget_name, widget_event, req.params
          # res.write "$('head > meta[name=csrf-token]').attr('content', '#{csrf_token}');"
          res.write '$(document).trigger("page:change");'
          res.finish
        else
          res
        end
      end

      private

      def req
        @req ||= Rack::Request.new(@env)
      end

      def res
        @res ||= begin
          if not widget_path
            @app.call(req.env)
          else
            status, headers, body = [
              200,
              {"Content-Type" => "text/javascript; charset=utf-8"},
              [""]
            ]
            Rack::Response.new(body, status, headers)
          end
        end
      end

      def widget_path
        path[Regexp.new("^#{Widget.config.url_path}($|\\?.*)")]
      end

      def path
        @env['PATH_INFO']
      end
    end
  end
end
