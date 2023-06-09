# frozen_string_literal: true

require 'i18n'
require 'http'
require 'deep_merge'
require_relative 'cache'

module I18n
  module Http
    module Backend
      class Runner
        include ::I18n::Backend::Base

        # Return the available locales.
        attr_reader :available_locales

        BASE_URL = 'https://raw.githubusercontent.com/dezsirazvan/translations/master'

        # Initialize a new instance of Runner with optional HTTP options.
        # Fetch the remote locales and merge them with the available locales from I18n.
        def initialize(original_backend: I18n.backend, http_options: {}, cache: nil)
          @original_backend = original_backend
          @http_options = http_options
          @cache = Cache.new(cache)
          @available_locales = (fetch_remote_locales + I18n.available_locales).uniq
        end

        # Fetch the remote translations for the given locale.
        # Fetch from cache if available, otherwise fetch from remote and store in cache.
        # If there is a cache miss or failure, fall back to the local translations.
        def available_translations(locale)
          translations = fetch_from_cache(locale)
          return translations if translations

          translations = fetch_remote_translations(locale)
          store_in_cache(locale, translations) if translations
          translations
        end

        # Translate the given key for the given locale.
        # If the translation is not available remotely, fallback to the local translation.
        def translate(locale, key, _options = {})
          translation = fetch_translation(locale, key)

          if translation.nil?
            @original_backend&.translate(locale, key, options = {})
          else
            translation
          end
        rescue StandardError => e
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
          translations = available_translations(locale.to_sym) || {}
          translations[key.to_sym]
        end

        # Set up the HTTP client with default headers and timeouts.
        def http_client
          HTTP.headers(accept: 'application/json').timeout(connect: 2, read: 5).follow
        end

        # Get the base URL for the remote translations.
        # Default to 'http://example.com' if not specified in @http_options.
        def base_url
          @http_options[:base_url] || BASE_URL
        end

        # Fetch the translations for the given locale from the cache.
        def fetch_from_cache(locale)
          @cache.fetch(locale) do
            fetch_remote_translations(locale)
          end
        end

        # Store the translations for the given locale in the cache.
        def store_in_cache(locale, translations)
          @cache.write(locale, translations)
        end
      end
    end
  end
end
