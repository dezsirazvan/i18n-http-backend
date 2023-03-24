# frozen_string_literal: true

require 'spec_helper'
require 'http'

RSpec.describe I18n::Http::Backend::Runner do
  let(:backend) { described_class.new }

  before do
    # Stub requests for fetching remote locales and translations
    stub_request(:get, 'http://example.com/locales')
      .to_return(status: 200, body: '{"locales":["en","fr","es"]}', headers: {})
    stub_request(:get, 'http://example.com/translations/en')
      .to_return(status: 200, body: '{"hello":"Hello","world":"World"}', headers: {})
    stub_request(:get, 'http://example.com/translations/fr')
      .to_return(status: 404, body: '', headers: {})
    stub_request(:get, 'http://example.com/translations/es')
      .to_return(status: 200, body: '{"hello":"Hola","world":"Mundo"}', headers: {})
  end

  describe '#available_locales' do
    it 'returns the available locales' do
      expect(backend.available_locales).to eq(%i[en fr es])
    end
  end

  describe '#available_translations' do
    context 'when the remote translation exists' do
      it 'returns the available translations including remote and local translations' do
        local_translations = { en: { hello: 'Local Hello' } }
        allow(I18n.backend).to receive(:translations).and_return(local_translations)

        expect(backend.available_translations(:en)).to eq({ hello: 'Hello' }.merge(local_translations[:en]))
      end
    end

    context "when the remote translation doesn't exist" do
      it 'returns the available translations including local translations only' do
        local_translations = { fr: { bonjour: 'Bonjour' } }
        allow(I18n.backend).to receive(:translations).and_return(local_translations)

        expect(backend.available_translations(:fr)).to eq(local_translations[:fr])
      end
    end

    context 'when the remote translations are updated' do
      it 'updates the remote translations' do
        stub_request(:get, 'http://example.com/translations/en').to_return(status: 200,
                                                                           body: '{"hello":"Updated Hello","world":"Updated World"}', headers: {})
        backend.available_translations(:en)

        expect(backend.available_translations(:en)['hello']).to eq('Updated Hello')
        expect(backend.available_translations(:en)['world']).to eq('Updated World')
      end
    end
  end

  describe '#translate' do
    before do
      I18n.available_locales = %i[en fr]
    end

    context 'when the remote translation exists' do
      it 'returns the translated string' do
        expect(backend.translate(:en, 'hello')).to eq('Updated Hello')
      end
    end

    context "when the remote translation doesn't exist" do
      it 'falls back to the default translation' do
        expect(backend.translate(:fr, 'hello')).to eq('translation missing: fr.hello')
      end
    end
  end
end
