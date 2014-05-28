module Cuba::Tools
  module Widget
    module Helpers
      def self.setup app
        require 'cuba/tools/mab'
        # load up all the widgets if we have a path
        if path = Widget.config.view_path
          Dir["#{path}/**/*.rb"].each  { |rb| require rb  }
        end

        if defined?(Slim) && defined?(Slim::Engine)
          Slim::Engine.set_default_options \
            disable_escape: true,
            use_html_safe: false,
            disable_capture: false,
            pretty: false
        end
      end

      def method_missing(meth, *args, &block)
        widget = req.env[:loaded_widgets][req.env[:widget_name].to_sym]

        if widget and widget.respond_to? meth
          widget.send meth, *args, &block
        else
          super
        end
      end

      def widget_div opts = {}, &block
        w_name  = req.env[:widget_name].to_s.gsub(/_/, '-')
        w_state = req.env[:widget_state].to_s.gsub(/_/, '-')

        defaults = {
          id: "#{w_name}-#{w_state}"
        }.merge opts

        name   = req.env[:widget_name].to_sym
        widget = req.env[:loaded_widgets][name]

        html = block.call widget

        mab do
          div(defaults) { html }
        end
      end

      def render_widget *args
        Widget.load_all(self, req, res)

        if args.first.kind_of? Hash
          opts = args.first
          name = req.env[:widget_name]
        else
          name = args.first
          opts = args.length > 1 ? args.last : {}
        end

        # set the current state (the method that will get called on render_widget)
        state = opts[:state] || 'display'

        widget = req.env[:loaded_widgets][name]

        if widget.method(state).parameters.length > 0
          widget.send state, opts.to_deep_ostruct
        else
          widget.send state
        end
      end

      def url_for_event event, options = {}
        widget_name = options.delete(:widget_name) || req.env[:widget_name]
        "http#{req.env['SERVER_PORT'] == '443' ? 's' : ''}://#{req.env['HTTP_HOST']}#{Widget.config.url_path}?widget_event=#{event}&widget_name=#{widget_name}" + (options.any?? '&' + URI.encode_www_form(options) : '')
      end

      def render_widgets
        res.headers["Content-Type"] = "text/javascript; charset=utf-8"
        widget_name, widget_event, events = Widget.load_all self, req, res
        events.trigger widget_name, widget_event, req.params
        # res.write "$('head > meta[name=csrf-token]').attr('content', '#{csrf_token}');"
        res.write '$(document).trigger("page:change");'
      end
    end
  end
end
