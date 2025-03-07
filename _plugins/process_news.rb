require 'nokogiri'
require 'open-uri'
require 'jekyll'

module Jekyll
  module NewsMetadata
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

  Jekyll.logger.info "News Metadata:", "Fetching metadata for #{document} from #{url}"

  metadata = Jekyll::NewsMetadata::MetadataFetcher.fetch(url)

  if not document.data['title']
    document.data['title'] ||= metadata[:title] if metadata[:title]
  end
  if not document.data['description']
    document.data['description'] ||= metadata[:description] if metadata[:description]
  end
  document.data['image'] ||= metadata[:image] if metadata[:image]
end

