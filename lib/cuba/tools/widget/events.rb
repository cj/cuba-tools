require "observer"

module Cuba::Tools
  module Widget
    class Events < Struct.new(:res, :req)
      include Observable

      def trigger widget_name, widget_event, user_data = {}
        data = user_data.to_deep_ostruct

        # THIS IS WHAT WILL MAKE SURE EVENTS ARE TRIGGERED
        changed
        ##################################################

        notify_observers widget_name, widget_event, data
      end
    end
  end
end
