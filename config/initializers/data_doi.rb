Sufia.config do |config|
  config.doi_credentials = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'doi_credentials.yml'))).result)[Rails.env].with_indifferent_access
end
