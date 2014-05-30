module Cuba::Tools
  module Widget
    class Base
      JS_ESCAPE     = { '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" }
      PARTIAL_REGEX = Regexp.new '([a-zA-Z_]+)$'
      VIEW_TYPES    = %w(slim erb haml)

      attr_accessor :app, :res, :req, :name, :events, :widget_state

      def initialize app, res, req, name, events
        @app          = app
        @res          = res
        @req          = req
        @name         = name.to_s
        @events       = events
        @widget_state = false

        events.add_observer self, :trigger_event
      end

      def set_state state
        @widget_state = state
      end

      def reset_state
        @widget_state = false
      end

      def render_state options = {}
        state = widget_state || options.delete(:state)

        if method(state).parameters.length > 0
          send(state, options.to_deep_ostruct)
        else
          send(state)
        end
      end

      def trigger widget_event, data = {}
        widget_name = data.delete(:for)

        req.env[:loaded_widgets].each do |n, w|
          w.trigger_event (widget_name || req.params['widget_name']), widget_event,
            data.to_deep_ostruct
        end
      end

      def trigger_event widget_name, widget_event, data = {}
        if class_events = self.class.events
          class_events.each do |class_event, opts|
            if class_event.to_s == widget_event.to_s && (
              widget_name.to_s == name or
              opts[:for].to_s == widget_name.to_s
            )
              if not opts[:with]
                e = widget_event
              else
                e = opts[:with]
              end

              if method(e) and method(e).parameters.length > 0
                send(e, data)
              else
                send(e)
              end
            end
          end
        end
      end

      def render *args
        if args.first.kind_of? Hash
          locals = args.first
          # if it's a partial we add an underscore infront of it
          state = view = locals[:state] ||
            "#{locals[:partial]}".gsub(PARTIAL_REGEX, '_\1')
        else
          state = view = args.first
          locals = args.length > 1 ? args.last : {}
        end

        # set the state and view if it's blank
        if view.blank?
          state = view = caller[0][/`.*'/][1..-2]
        # override state if widget_state set
        elsif !locals[:state] && widget_state
          state = widget_state
        end

        req.env[:widget_name]  = name
        req.env[:widget_state] = state

        view_folder = self.class.to_s.gsub(
          /\w+::Widgets::/, ''
        ).split('::').map(&:underscore).join('/')

        # check for the extension
        file = false
        VIEW_TYPES.each do |type|
          file = "#{view_path}/#{view_folder}/#{view}.#{type}"
          if File.file? file
            break
          else
            file = false
          end
        end

        app.render file, locals
      end

      def partial template, locals = {}
        locals[:partial] = template
        render locals
      end

      def current_user
        app.current_user
      end

      def view_path
        Widget.config.view_path
      end

      def replace state, opts = {}
        if !state.is_a? String
          opts[:state] = state
          content = render_state opts
          selector = '#' + id_for(state)
        else
          if !opts.key?(:content) and !opts.key?(:with)
            opts[:state] = caller[0][/`.*'/][1..-2]
            content = render_state opts
          else
            content = opts[:content] || opts[:with]
          end
          selector = state
        end

        res.write '$("' + selector + '").replaceWith("' + escape(content) + '");'
        # scroll to the top of the page just as if we went to the url directly
        # if opts[:scroll_to_top]
        #   res.write 'window.scrollTo(0, 0);'
        # end
      end

      def id_for state
        w_name  = req.env[:widget_name].to_s.gsub(/_/, '-')
        w_state = state.to_s.gsub(/_/, '-')

        "#{w_name}-#{w_state}"
      end

      def escape js
        js.to_s.gsub(/(\\|<\/|\r\n|\\3342\\2200\\2250|[\n\r"'])/) {|match| JS_ESCAPE[match] }
      end

      class << self
        attr_accessor :events, :available_helper_methods

        def respond_to event, opts = {}
          @events ||= []
          @events << [event.to_s, opts]
        end

        def responds_to *events
          @events ||= []
          events.each do |event|
            @events << [event, {}]
          end
        end
      end
    end
  end
end
