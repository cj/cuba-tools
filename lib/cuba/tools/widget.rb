module Cuba::Tools
  module Widget
    autoload :Responder,  "cuba/tools/widget/responder"
    autoload :Middleware, "cuba/tools/widget/middleware"
    autoload :Helpers,    "cuba/tools/widget/helpers"
    autoload :Base,       "cuba/tools/widget/base"
    autoload :Events,     "cuba/tools/widget/events"

    extend self

    attr_accessor :config, :reset_config, :load_all

    def setup
      yield config
    end

    def config
      @config || reset_config!
    end

    # Resets the configuration to the default (empty hash)
    def reset_config!
      @config = OpenStruct.new({
        url_path: '/widgets',
        widgets: {}
      })
    end

    def load_all app, req, res
      req.env[:loaded_widgets] ||= {}

      events = Events.new res, req

      if widget_event = req.params["widget_event"]
        widget_name = req.params["widget_name"]
      end

      Widget.config.widgets.each do |name, widget|
        req.env[:loaded_widgets][name] = Object.const_get(widget).new(
          app, res, req, name, events
        )
      end

      [widget_name, widget_event, events]
    end
  end
end
