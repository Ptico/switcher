guard 'rspec', :version => 2, :all_after_pass => true, :all_on_start => true,
  :cli => "--colour --format documentation --profile" do
  watch(%r{^lib/(.+)\.rb$})
  watch(%r{^spec/.+_spec\.rb$})
end
