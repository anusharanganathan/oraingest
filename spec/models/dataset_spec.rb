require 'rails_helper'

describe Dataset do
  it_behaves_like 'build_metadata'
  it_behaves_like 'doi_methods'
end