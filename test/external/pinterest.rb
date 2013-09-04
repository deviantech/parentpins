#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "capybara"
require "capybara/dsl"
require "capybara-webkit"

require 'debugger'



Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "http://www.pinterest.com/"




module Test
  class Pinterest
    include Capybara::DSL
    @@store_dir = File.expand_path( File.join( File.dirname(__FILE__), '../../db/pinterest-schema') )
    
    URL_USERNAME = 'kalidonovanppte'
    SELECTOR_FOR_MULTIPLE_BOARDS = '.secretBoardHeader'
    BOARD_SELECTOR = '.boardLinkWrapper'
    PIN_SELECTOR   = '.pinWrapper'
    
    EXPECTED = {
      :board_count => 2,
      :boards => [
        {
          :name => 'Travel',
          :URL => '/kalidonovanppte/travel/',
          :pin_count => 4
        },
        {
          :name => 'Secret Water',
          :URL => '/kalidonovanppte/secret-water/',
          :pin_count => 3
        }
      ],
      :pin => {
        :data_url => 'http://pinterest.com/pin/512988213776355446/',
        
        # From data_url
        :image_url  => 'http://media-cache-ec0.pinimg.com/736x/dc/66/c2/dc66c21f454fa0a40cf18676d319add6.jpg',
        :source_url => 'http://m.weheartit.com/entry/71002647/dashboard',
        
        # From board listing
        :description      => "India",
        :domain           => "m.weheartit.com",
        :price            => "",
        :small_image_URL  => "http://media-cache-ec0.pinimg.com/236x/dc/66/c2/dc66c21f454fa0a40cf18676d319add6.jpg",
        :pinterest_url    => "/pin/512988213776355446/"
      }
    }
    
    
    def initialize
      @cookie = File.read( File.join(@@store_dir, 'cookies.txt') )
      page.driver.browser.set_cookie @cookie
      check_cookie
    end
    
    def run_checks
      check_all_boards
      check_specific_board
      check_specific_pin
      puts "All appears OK"
    end
    
    def check_all_boards
      visit "/#{URL_USERNAME}/boards"

      raise "Missing #{SELECTOR_FOR_MULTIPLE_BOARDS} on board listing page" unless page.has_selector?(SELECTOR_FOR_MULTIPLE_BOARDS)
      raise "Unable to find all boards" unless page.all(BOARD_SELECTOR).count == EXPECTED[:board_count]
      
      page.all(BOARD_SELECTOR).each_with_index do |li, idx|
        check_board_mismatch idx, :name,      li.find('.boardName').text.gsub(/^\s*Secret Board\s*/i, '').strip
        check_board_mismatch idx, :URL,       li['href']
        check_board_mismatch idx, :pin_count, li.find('.boardPinCount').text.to_i
      end      
    end
        
    def check_specific_board
      visit EXPECTED[:boards][0][:URL]
      
      raise "Unable to find all pins for board" unless page.all(PIN_SELECTOR).count == EXPECTED[:boards][0][:pin_count]
      pin = page.first(PIN_SELECTOR)

      check_pin_match :description,     pin.find('.pinDescription').text
      check_pin_match :domain,          pin.find('.pinDomain').text
      check_pin_match :price,           pin.find('.priceValue').text
      check_pin_match :small_image_URL, pin.find('.pinImg.loaded')[:src]
      check_pin_match :pinterest_url,   pin.find('a.pinImageWrapper')[:href]
    end
    
    def check_specific_pin
      visit EXPECTED[:pin][:data_url]
      
      warn "Error getting information (source_url) for specfic pin" unless get_meta('og:see_also') == EXPECTED[:pin][:source_url]
      warn "Error getting information (image) for specfic pin" unless get_meta('og:image') == EXPECTED[:pin][:image_url]
    end
    
    protected
    
    def check_cookie
      visit('/')

      raise(StandardError, "Cookie failed to log us in -- perhaps expired?") if page.has_content?("Log in now")
    end

    def check_board_mismatch(idx, key, actual)
      expected = EXPECTED[:boards][idx][key]
      warn %Q{Expected board #{idx} to have #{key} "#{expected}", was "#{actual}"} unless expected == actual
    end

    def check_pin_match(key, actual)
      expected = EXPECTED[:pin][key]
      raise %Q{Expected pin to have #{key} "#{expected}", was #{actual}} unless expected == actual
    end
  
    # TODO: this isn't functioning as expected
    def get_meta(wanted)
      @meta_tags ||= all('meta')
      tag = @meta_tags.detect { |t| t[:name] == wanted || t[:property] == wanted }
      tag && tag[:content]
    end
    
  
  end
end

spider = Test::Pinterest.new
spider.run_checks

# TODO: make this run pass all checks
  # TODO: check how many HTTP requests required total. Reasonable to run frequently? 
  # TODO: Change user agent
  # TODO -- make warn a raise in check_specific_board, or otherwise fail. Skipping for now b/c pinterest's board count is off.

__END__

ruby test/external/pinterest.rb

