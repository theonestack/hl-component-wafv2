describe 'compiled component wafv2' do
  Dir.glob('tests/*.test.yaml').sort.each do |test|
    context test do
      it 'compiles test' do
        expect(system("cfhighlander cftest #{@validate} --tests #{test}")).to be_truthy
      end
    end
  end
end
