# frozen_string_literal: true

RSpec.describe I18n::Http::Backend do
  it 'has a version number' do
    expect(I18n::Http::Backend::VERSION).not_to be nil
  end
end
