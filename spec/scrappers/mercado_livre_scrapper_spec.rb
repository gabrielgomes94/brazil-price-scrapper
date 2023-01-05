# frozen_string_literal: true

require 'scrappers/mercado_livre_scrapper'

RSpec.describe BrazilPrices::Scrappers::MercadoLivreScrapper do
  it 'crawls and scrape prices from Mercado Livre' do
    node = double(Ferrum::Node)
    page = double(Ferrum::Page)

    scrapper = BrazilPrices::Scrappers::MercadoLivreScrapper.new page

    stub_page(page, node)
    stub_price_parsing(node)
    stub_title_parsing(node)
    stub_link_parsing(node)
    allow(page).to receive(:css).with('li.andes-pagination__button--next').and_return(nil)
    
    expect { |block| scrapper.parse(&block) }.to yield_with_args(
           { title: 'Celular Xiaomi Redmi 8',
             price: 1999.9,
             link: 'http://www.mercadolivre.com.br/celular-xiaomi'
           }
         )
  end

  it 'scrape next page when button is available' do
    node = double(Ferrum::Node)
    page = double(Ferrum::Page)

    scrapper = BrazilPrices::Scrappers::MercadoLivreScrapper.new page

    stub_page(page, node)
    stub_price_parsing(node)
    stub_title_parsing(node)
    stub_link_parsing(node)
    request_stub = stub_next_page_button(page)

    expect { |block| scrapper.parse(&block) }
      .to yield_successive_args(
            {
              title: 'Celular Xiaomi Redmi 8',
              price: 1999.9,
              link: 'http://www.mercadolivre.com.br/celular-xiaomi'
            },
            request_stub
          )
  end

  private

  def stub_page(page, node)
    allow(page).to receive(:css).with('div.shops__result-wrapper').and_return([node])
  end

  def stub_price_parsing(node)
    price_element_node = instance_double(Ferrum::Node)
    allow(node).to receive(:css).with('span.price-tag-fraction').and_return(price_element_node)
    allow(price_element_node).to receive(:text).with(no_args).and_return('1.999,90')
  end

  def stub_title_parsing(node)
    title_element_node = instance_double(Ferrum::Node)
    allow(node).to receive(:css).with('h2.shops__item-title').and_return(title_element_node)
    allow(title_element_node).to receive(:text).with(no_args).and_return('Celular Xiaomi Redmi 8')
  end

  def stub_link_parsing(node)
    link_element_node = instance_double(Ferrum::Node)
    allow(node).to receive(:css).with('a.ui-search-link').and_return(link_element_node)
    allow(link_element_node).to receive(:attribute).with(:href).and_return('http://www.mercadolivre.com.br/celular-xiaomi')
  end

  def stub_next_page_button(page)
    button_node = instance_double(Ferrum::Node)
    allow(page).to receive(:css).with('li.andes-pagination__button--next').and_return(button_node)
    allow(button_node).to receive(:css).with('a').and_return(button_node_element)

    button_node_element = instance_double(Ferrum::Node)
    allow(button_node_element).to receive(:attribute).with(:href).and_return('http://www.mercadolivre.com.br/celular-xiaomi?page=2')
    allow(page).to receive(:current_url).and_return('http://www.mercadolivre.com.br/celular-xiaomi')

    request_instance = instance_double(Vessel::Request)
    allow(Vessel::Request).to receive(:new).with(url: 'http://www.mercadolivre.com.br/celular-xiaomi?page=2').and_return(request_instance)

    request_instance
  end
end