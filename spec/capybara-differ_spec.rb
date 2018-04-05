RSpec.describe Capybara::Differ do
  it "has a version number" do
    expect(Capybara::Differ::VERSION).not_to be nil
  end

  describe 'Comparator' do
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

    it "raises error when the given selector wasn't found" do
      comparator = Capybara::Differ::Comparator.new(fixture_file_path('test1a'), fixture_file_path('test1b'), selector: '.unknown')
      expect{
        comparator.compare
      }.to raise_error(/\.unknown/)
    end

    context 'options' do
      it "accepts the context option of diffy" do
        comparator = Capybara::Differ::Comparator.new(fixture_file_path('test_context_a'), fixture_file_path('test_context_b'))
        result = comparator.compare
        expect(result).to match(%r{\-\s+ABC})
        expect(result).to include('line2')
        expect(result).not_to include('line1')

        comparator = Capybara::Differ::Comparator.new(fixture_file_path('test_context_a'), fixture_file_path('test_context_b'), diffy: {context: 3})
        result = comparator.compare
        expect(result).to match(%r{\-\s+ABC})
        expect(result).to include('line1')
      end

      it "accepts the include_diff_info option of diffy" do
        comparator = Capybara::Differ::Comparator.new(fixture_file_path('test_context_a'), fixture_file_path('test_context_b'), diffy: {include_diff_info: false})
        result = comparator.compare
        expect(result).not_to include('@@')
        expect(result).to match(%r{\-\s+ABC})
        expect(result).not_to include('line1')
      end

      it "accepts format option to change output with diffy" do
        comparator = Capybara::Differ::Comparator.new(fixture_file_path('test_context_a'), fixture_file_path('test_context_b'), diffy: {format: :html})
        result = comparator.compare
        expect(result).to include('class="del"')
      end
    end
  end
end
