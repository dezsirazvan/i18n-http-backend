# frozen_string_literal: true

require 'redis'
require 'active_support'

module I18n
  module Http
    module Backend
      class Cache
        def initialize(cache)
          @cache = cache || cache_config
        end

        def fetch(locale, &block)
          @cache.fetch(cache_key_for(locale), expires_in: 1.hour, &block)
        end

        def write(locale, translations)
          @cache.write(cache_key_for(locale), translations)
        end

        private

        def cache_config
          if ENV['REDIS_URL']
            Redis.new(url: ENV['REDIS_URL'])
          else
            ActiveSupport::Cache::MemoryStore.new
          end
        end

        def cache_key_for(locale)
          "i18n-http-backend:#{locale}"
        end
      end
    end
  end
end
