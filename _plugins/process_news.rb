require 'nokogiri'
require 'open-uri'
require 'jekyll'
require 'singleton'
require 'fileutils'

module Jekyll
  module NewsMetadata
    class CacheManager
      include Singleton
      CACHE_FILE = File.join(Dir.pwd, '.jekyll-cache', 'news_metadata_cache.yml')

      def initialize
        @cache = load_cache
      end

      def check_cache(document, current_url)
        key = document.relative_path
        entry = @cache[key]
        return false unless entry
        entry['url'] == current_url
      end

      def update_cache(document, current_url)
        key = document.relative_path
        @cache[key] = { 'url' => current_url, 'timestamp' => Time.now.to_i }
      end

      def save
        FileUtils.mkdir_p(File.dirname(CACHE_FILE))
        File.write(CACHE_FILE, @cache.to_yaml)
      end

      private

      def load_cache
        return {} unless File.exist?(CACHE_FILE)
        YAML.load_file(CACHE_FILE) || {}
      rescue => e
        Jekyll.logger.warn "Metadata Cache Error:", "Loading cache: #{e.message}"
        {}
      end
    end

    class MetadataFetcher
      def self.fetch(url)
        begin
          html = URI.parse(url).open(read_timeout: 10)
          doc = Nokogiri::HTML(html)

          {
            title: extract_title(doc),
            description: extract_description(doc),
            image: extract_image(doc)
          }.compact
        rescue StandardError => e
          Jekyll.logger.warn "News Metadata Error:", "Failed to fetch #{url}: #{e.message}"
          {}
        end
      end

      private

      def self.extract_title(doc)
        doc.at_css('title')&.text || doc.at_css('meta[property="og:title"]')&.attr('content')
      end

      def self.extract_description(doc)
        doc.at_css('meta[name="description"]')&.attr('content') ||
        doc.at_css('meta[property="og:description"]')&.attr('content')
      end

      def self.extract_image(doc)
        doc.at_css('meta[property="og:image"]')&.attr('content') ||
        doc.at_css('meta[name="twitter:image"]')&.attr('content')
      end
    end
  end
end

Jekyll::Hooks.register :news, :pre_render do |document|
  next unless (url = document.data['more'])
  next if document.data['image']

  cache = Jekyll::NewsMetadata::CacheManager.instance
  relative_path = document.relative_path

  # Check cache validity
  if cache.check_cache(document, url)
    Jekyll.logger.debug "News Metadata Cache:", "Using cached data for #{relative_path}"
    next
  end

  Jekyll.logger.info "News Metadata:", "Fetching metadata for #{document} from #{url}"

  metadata = Jekyll::NewsMetadata::MetadataFetcher.fetch(url)

  if not document.data['title']
    document.data['title'] ||= metadata[:title] if metadata[:title]
  end
  if not document.data['description']
    document.data['description'] ||= metadata[:description] if metadata[:description]
  end
  document.data['image'] ||= metadata[:image] if metadata[:image]

  # Update cache with new values
  cache.update_cache(document, url)
end

Jekyll::Hooks.register :site, :post_write do |site|
  Jekyll::NewsMetadata::CacheManager.instance.save
  Jekyll.logger.info "News Metadata:", "Cache saved successfully"
end

