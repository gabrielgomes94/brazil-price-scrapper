# frozen_string_literal: true
module BrazilPrices
  module Scrappers
    class MercadoLivreScrapper < Vessel::Cargo
      PRODUCT_CONTAINER_SELECTOR = 'div.shops__result-wrapper'
      PRODUCT_LINK_SELECTOR = 'a.ui-search-link'
      PRODUCT_PRICE_SELECTOR = 'span.price-tag-fraction'
      PRODUCT_TITLE_SELECTOR = 'h2.shops__item-title'
      NEXT_PAGE_SELECTOR = 'li.andes-pagination__button--next'

      domain "mercadolivre.com.br"

      def self.base_url
        'https://lista.mercadolivre.com.br/'
      end

      def self.settings
        @settings ||= super.settings
        @settings[:ferrum] = {
          browser_options: {
            'no-sandbox': nil,
          }
        }
        @settings
      end

      def parse
        css(PRODUCT_CONTAINER_SELECTOR).each do |element|
          price_element = element.at_css(PRODUCT_PRICE_SELECTOR).text
          price = parse_price(price_element)
          title = element.at_css(PRODUCT_TITLE_SELECTOR).text
          link = element.at_css(PRODUCT_LINK_SELECTOR).attribute(:href)

          yield({
            title: title,
            price: price.to_f,
            link: link
          })
        end

        next_page = at_css(NEXT_PAGE_SELECTOR)

        if next_page
          link = next_page.at_css('a').attribute(:href)

          yield request(url: absolute_url(link))
        end
      end

      def parse_price(price)
        price.gsub!('.', '')
        price.gsub!(/[[:space:]]/, '')
        price.gsub!(',', '.')

        price
      end
    end
  end
end