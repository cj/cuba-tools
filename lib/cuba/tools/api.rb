module Cuba::Tools
  module Api
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
        path: './app/api_params',
        user_class: 'User'
      })
    end

    class ValidationError < RuntimeError
      attr_reader :errors

      def initialize errors
        @errors = errors
      end
    end

    module Helpers
      def self.setup app
        require 'yaml'
      end

      def api_params key, klass
        params = add_attributes_for req.params[key.to_s]

        @api_params ||= YAML.load_file "#{Api.config.path}/#{key}.yml"

        form = klass.restrict!(current_user).new

        if form.validates params, as: current_user
          lambda { captures << form; captures << params }
        else
          raise ValidationError.new(form.errors), 'Api Validation Failed'
        end
      end

      def api_signature
        api_request = Signature::Request.new(
          req.request_method,
          req.path,
          req.params,
          req.env
        )

        user = false

        api_request.authenticate do |key|
          user = user_class.where(api_key: key).first
          Signature::Token.new key, user.try(:api_secret)
        end

        sign_in user
      end

      def add_attributes_for params
        params.dup.each do |key, value|
          if !key[/_attributes$/] && value.is_a?(Hash)
            params["#{key}_attributes"] = add_attributes_for value
            params.delete key
          end
        end

        params
      end

      private

      def user_class
        Cuba::Tools::Auth.config.user_class.constantize
      end
    end
  end
end
