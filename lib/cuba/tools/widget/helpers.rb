module Cuba::Tools
  module Widget
    module Helpers
      def self.setup app
        require 'cuba/tools/mab'
        # load up all the widgets if we have a path
        if path = Widget.config.view_path
          Dir["#{path}/**/*.rb"].each  { |rb| require rb  }
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

      def render_widget *args
        Widget.load_all(self, req, res) unless req.env[:loaded_widgets]

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
          widget.send state, opts.to_deep_struct
        else
          widget.send state
        end
      end

      def replace state, opts = {}
        set_state state

        if !state.is_a? String
          opts[:state] = state
          content = render_state, opts
          selector = '#' + id_for(state)
        else
          if !opts.key?(:content) and !opts.key?(:with)
            content = render_state opts
          else
            content = opts[:content] || opts[:with]
          end
          selector = state
        end

        reset_state

        res.write '$("' + selector + '").replaceWith("' + escape(content) + '");'
        # scroll to the top of the page just as if we went to the url directly
        # if opts[:scroll_to_top]
        #   res.write 'window.scrollTo(0, 0);'
        # end
      end

      def escape js
        js.to_s.gsub(/(\\|<\/|\r\n|\\3342\\2200\\2250|[\n\r"'])/) {|match| JS_ESCAPE[match] }
      end

      def widget_div opts = {}, &block
        defaults = {
          id: "#{req.env[:widget_name]}_#{req.env[:widget_state]}"
        }.merge opts

        name   = req.env[:widget_name].to_sym
        widget = req.env[:loaded_widgets][name]

        html = block.call widget

        mab do
          div(defaults) { html }
        end
      end
    end
  end
end
