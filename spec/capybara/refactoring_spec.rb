RSpec.describe Capybara::Refactoring do
  it "has a version number" do
    expect(Capybara::Refactoring::VERSION).not_to be nil
  end

  describe 'Differ' do
    def fixture_file_path(name)
      File.join('spec', 'fixtures', 'files', "#{name}.html")
    end

    it "returns true when given paths are the same" do
      differ = Capybara::Refactoring::Differ.new('same_path.html', 'same_path.html')
      expect(differ.compare).to be_truthy
    end

    it "outputs line diff" do
      differ = Capybara::Refactoring::Differ.new(fixture_file_path('test1a'), fixture_file_path('test1b'))
      expect(differ.compare).to match(%r{\-\s+ABC})
      expect(differ.compare).to match(%r{\+\s+DEF})
    end

    it "outputs line diff with scoping with selector" do
      differ = Capybara::Refactoring::Differ.new(fixture_file_path('test2a'), fixture_file_path('test2b'), selector: '.target')
      expect(differ.compare).to match(%r{\-\s+abc})
      expect(differ.compare).to match(%r{\+\s+def})
      expect(differ.compare).not_to match(%r{\-\s+ABC})
      expect(differ.compare).not_to match(%r{\+\s+DEF})
    end

    it "outputs blank line with equivalent files" do
      differ = Capybara::Refactoring::Differ.new(fixture_file_path('test2a'), fixture_file_path('test2a_copy'), selector: '.target')
      expect(differ.compare).to eql("\n")
    end

    it "raises error when the given file doesn't exist" do
      differ = Capybara::Refactoring::Differ.new(fixture_file_path('test1a'), fixture_file_path('unknown'))
      expect{
        differ.compare
      }.to raise_error(ArgumentError)
    end
  end
end
