require 'byebug'
require 'htmlbeautifier'
require 'diffy'
require 'capybara'
require "capybara-differ/version"

module Capybara
  module Differ

    class Comparator
      def initialize(old_file_path, new_file_path, options = {})
        @old_file_path = old_file_path
        @new_file_path = new_file_path
        @options = options
      end

      def compare
        if @old_file_path == @new_file_path
          puts "There is no history of snapshots"
          return ''
        end
        puts "Comparing two files#{target_selector ? ' with selector [' + target_selector + ']' : ''}\n  #{@old_file_path}\n  #{@new_file_path}"
        old_html = beautified_html(@old_file_path)
        new_html = beautified_html(@new_file_path)
        Diffy::Diff.new(old_html, new_html, context: diffy_options.fetch(:context, 2)).to_s(:color)
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

      def diffy_options
        @options.fetch(:diffy, {})
      end
    end

    def check_page(name, options = {})
      filename = File.join(name, Time.now.strftime('%Y%m%d%H%M%S') + '.html')
      save_page(filename)

      base_dir = File.join([Capybara.save_path, name].compact)
      old_html_path = Dir[File.join(base_dir, '*')].first
      new_html_path = Dir[File.join(base_dir, '*')].last

      comparator = Capybara::Differ::Comparator.new(old_html_path, new_html_path, options)
      if (result = comparator.compare).strip.size > 0
        puts result
      else
        puts "No difference on '#{name}' snapshots"
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Differ)
