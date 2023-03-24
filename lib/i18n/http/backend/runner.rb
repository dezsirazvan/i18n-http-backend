# frozen_string_literal: true

require 'i18n'
require 'http'
require 'deep_merge'
require 'byebug'

module I18n
  module Http
    module Backend
      class Runner
        include ::I18n::Backend::Base

        # Return the available locales.
        attr_reader :available_locales

        # Initialize a new instance of Runner with optional HTTP options.
        # Fetch the remote locales and merge them with the available locales from I18n.
        def initialize(http_options = {})
          @original_backend = I18n.backend
          @http_options = http_options
          @available_locales = (fetch_remote_locales + I18n.available_locales).uniq
        end

        def translations
          # Return local translations
          @original_backend.translations
        end

        # Fetch the remote translations for the given locale and merge them with the local translations.
        def available_translations(locale)
          remote_translations = fetch_remote_translations(locale)
          local_translations = translations.dig(locale) || {}

          if remote_translations
            remote_translations.deep_merge(local_translations)
          else
            local_translations
          end
        end

        # Translate the given key for the given locale.
        # If the translation is not available remotely, fallback to the local translation.
        def translate(locale, key, options = {})
          translation = fetch_translation(locale, key)
          if translation.nil?
            # Delegate to the next backend in the chain
            super
          else
            translation
          end
        rescue NotImplementedError => e
          puts "Translation Error: #{e.message}"
          "translation missing: #{locale}.#{key}"
        end        

        private

        # Fetch the remote locales via HTTP.
        # Parse the response body and convert locales to symbols.
        # Return an empty array if the HTTP request fails.
        def fetch_remote_locales
          response = http_client.get("#{base_url}/locales.json")

          if response.status.success?
            JSON.parse(response.to_s)['locales'].map(&:to_sym)
          else
            []
          end
        end

        # Fetch the remote translations for the given locale via HTTP.
        # Parse the response body and return the JSON object or nil if the HTTP request fails.
        def fetch_remote_translations(locale)
          response = http_client.get("#{base_url}/#{locale}.json")

          JSON.parse(response.body).transform_keys(&:to_sym) if response.status.success?
        rescue HTTP::Error
          nil
        end

        # Fetch the remote translation for the given key and locale.
        def fetch_translation(locale, key)
          translations = available_translations(locale.to_sym)
          translations[key.to_sym] || translations[key.to_s]
        end

        # Set up the HTTP client with default headers and timeouts.
        def http_client
          HTTP.headers(accept: 'application/json').timeout(connect: 2, read: 5).follow
        end

        # Get the base URL for the remote translations.
        # Default to 'http://example.com' if not specified in @http_options.
        def base_url
          @http_options[:base_url] || 'https://raw.githubusercontent.com/dezsirazvan/translations/master'
        end
      end
    end
  end
end
