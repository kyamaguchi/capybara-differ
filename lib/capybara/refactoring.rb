require 'byebug'
require 'htmlbeautifier'
require 'diffy'
require 'capybara'
require "capybara/refactoring/version"

module Capybara
  module Refactoring

    class Differ
      def initialize(old_file_path, new_file_path, options = {})
        @old_file_path = old_file_path
        @new_file_path = new_file_path
        @options = options
      end

      def compare
        return true if @old_file_path == @new_file_path
        old_html = beautified_html(@old_file_path)
        new_html = beautified_html(@new_file_path)
        Diffy::Diff.new(old_html, new_html).to_s(:color)
      end

      def beautified_html(file)
        raise ArgumentError, "#{file} not found" unless File.exist?(file)
        doc = Nokogiri.HTML(File.read(file))

        # Add line breaks to get diff by elements
        doc.traverse do |x|
          x.content = "\n#{x.content.strip}\n" if x.text?
        end

        html = target_selector ? doc.css(target_selector).to_html : doc.to_html
        HtmlBeautifier.beautify(html)
      end

      private

      def target_selector
        @options.fetch(:selector, nil)
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Refactoring)
