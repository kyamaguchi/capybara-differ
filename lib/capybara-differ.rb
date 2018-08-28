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
        if @old_file_path.nil? || @new_file_path.nil? || @old_file_path == @new_file_path
          puts "There is no history of snapshots"
          return ''
        end
        puts "Comparing two files" + (target_selector ? " with selector [#{target_selector}]" : '')
        old_beautified_html_path = beautified_html(@old_file_path)
        new_beautified_html_path = beautified_html(@new_file_path)
        if use_diffy?
          puts "  #{@old_file_path}\n  #{@new_file_path}" unless diffy_options[:include_diff_info]
          diff = Diffy::Diff.new(old_beautified_html_path, new_beautified_html_path, diffy_options.merge(source: 'files'))
          diff.to_s(diffy_options.fetch(:format, :color))
        else
          cmd = "git diff --no-index --color-words --word-diff-regex='\w+|[^[:space:]=\"<>]+' #{old_beautified_html_path} #{new_beautified_html_path}"
          Open3.popen3(cmd) { |i, o, e| o.read }
        end
      end

      def beautified_html(file)
        raise ArgumentError, "#{file} not found" unless File.exist?(file)
        doc = Nokogiri.HTML(File.read(file))

        # Add line breaks to get diff by elements
        doc.traverse do |x|
          x.content = "\n#{x.content.strip}\n" if x.text?
        end

        node = doc.css(target_selector || default_selector)
        raise("Couldn't find the selector [#{target_selector}] in #{file}") if node.empty?
        beautified_html = HtmlBeautifier.beautify(node.to_html)

        beautified_html_path = file + '.beauty'
        File.write(beautified_html_path, beautified_html)
        beautified_html_path
      end

      private

      def target_selector
        @options.fetch(:selector, nil)
      end

      def default_selector
        'body > *'
      end

      def diffy_options
        opt = {context: 2, include_diff_info: true}
        @options[:diffy].is_a?(Hash) ? opt.merge(@options[:diffy]) : opt
      end

      def use_diffy?
        @options.has_key?(:diffy)
      end
    end

    def check_page(name, options = {})
      raise ArgumentError, 'options must be hash' unless options.is_a?(Hash)
      path_from_name = name.gsub(/[^a-z0-9\-_]+/i, '_')
      filename = File.join(path_from_name, Time.now.strftime('%Y%m%d%H%M%S') + '.html')
      save_page(filename)

      base_dir = File.join([Capybara.save_path, path_from_name].compact)
      file_list = Dir[File.join(base_dir, '*.html')].sort
      old_html_path = options[:compare_with] == :previous ? file_list[-2] : file_list.first
      new_html_path = file_list.last

      comparator = Capybara::Differ::Comparator.new(old_html_path, new_html_path, options)
      if (result = comparator.compare).strip.size > 0
        puts result
      else
        puts "No difference on '#{path_from_name}' snapshots"
      end
    end
  end
end

Capybara::Session.send(:include, Capybara::Differ)
