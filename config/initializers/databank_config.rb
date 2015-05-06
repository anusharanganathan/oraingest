Sufia.config do |config|
  config.databank_credentials = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'databank_credentials.yml'))).result)[Rails.env].with_indifferent_access
end
