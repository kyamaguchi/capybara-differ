require 'byebug'
require 'htmlbeautifier'
require 'diffy'
require 'capybara'
require "capybara/refactoring/version"

module Capybara
  module Refactoring

    class Differ
      def initialize(old_file_path, new_file_path)
        @old_file_path = old_file_path
        @new_file_path = new_file_path
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
        HtmlBeautifier.beautify(doc.to_html)
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Refactoring)
