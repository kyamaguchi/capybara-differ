RSpec.describe Capybara::Differ do
  it "has a version number" do
    expect(Capybara::Differ::VERSION).not_to be nil
  end

  describe 'Differ' do
    def fixture_file_path(name)
      File.join('spec', 'fixtures', 'files', "#{name}.html")
    end

    it "returns true when given paths are the same" do
      comparator = Capybara::Differ::Comparator.new('same_path.html', 'same_path.html')
      expect(comparator.compare).to be_truthy
    end

    it "outputs line diff" do
      comparator = Capybara::Differ::Comparator.new(fixture_file_path('test1a'), fixture_file_path('test1b'))
      result = comparator.compare
      expect(result).to match(%r{\-\s+ABC})
      expect(result).to match(%r{\+\s+DEF})
    end

    it "outputs line diff with scoping with selector" do
      comparator = Capybara::Differ::Comparator.new(fixture_file_path('test2a'), fixture_file_path('test2b'), selector: '.target')
      result = comparator.compare
      expect(result).to match(%r{\-\s+abc})
      expect(result).to match(%r{\+\s+def})
      expect(result).not_to match(%r{\-\s+ABC})
      expect(result).not_to match(%r{\+\s+DEF})
    end

    it "outputs blank line with equivalent files" do
      comparator = Capybara::Differ::Comparator.new(fixture_file_path('test2a'), fixture_file_path('test2a_copy'), selector: '.target')
      expect(comparator.compare).to eql("\n")
    end

    it "outputs line diff with adding line breaks to each element for one line content" do
      comparator = Capybara::Differ::Comparator.new(fixture_file_path('test2a_oneline'), fixture_file_path('test2b_oneline'), selector: '.target')
      result = comparator.compare
      expect(result).to match(%r{\-\s+abc})
      expect(result).to match(%r{\+\s+def})
      expect(result).not_to match(%r{\-\s+ABC})
      expect(result).not_to match(%r{\+\s+DEF})
    end

    it "raises error when the given file doesn't exist" do
      comparator = Capybara::Differ::Comparator.new(fixture_file_path('test1a'), fixture_file_path('unknown'))
      expect{
        comparator.compare
      }.to raise_error(ArgumentError)
    end
  end
end
