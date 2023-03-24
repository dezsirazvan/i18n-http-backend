require 'spec_helper'
require 'i18n/http/backend'

RSpec.describe I18n::Backend::Http::HttpBackend do
  let(:backend) { described_class.new }

  describe '#available_locales' do
    context 'when remote locales are available' do
      before do
        allow(backend).to receive(:fetch_remote_locales).and_return(['fr', 'es'])
      end

      it 'returns the remote and local locales' do
        expect(backend.available_locales).to match_array(['fr', 'es', :en])
      end
    end

    context 'when remote locales are not available' do
      before do
        allow(backend).to receive(:fetch_remote_locales).and_raise(StandardError)
      end

      it 'returns only the local locales' do
        expect(backend.available_locales).to match_array([:en])
      end
    end
  end

  describe '#available_translations' do
    context 'when remote translations are available' do
      before do
        allow(backend).to receive(:fetch_remote_translation).with('fr', 'hello')
                                                           .and_return('Bonjour')
        allow(backend).to receive(:fetch_remote_translation).with('es', 'hello')
                                                           .and_return('Hola')
      end

      it 'returns the remote and local translations' do
        expect(backend.available_translations).to eq({
          'fr' => { 'hello' => 'Bonjour' },
          'es' => { 'hello' => 'Hola' },
          :en => { 'hello' => 'Hello' }
        })
      end
    end

    context 'when remote translations are not available' do
      before do
        allow(backend).to receive(:fetch_remote_translation).and_raise(StandardError)
      end

      it 'returns only the local translations' do
        expect(backend.available_translations).to eq({
          :en => { 'hello' => 'Hello' }
        })
      end
    end
  end

  describe '#translate' do
    context 'when the translation key is available locally' do
      it 'returns the local translation' do
        expect(backend.translate(:en, 'hello')).to eq('Hello')
      end
    end

    context 'when the translation key is available remotely' do
      before do
        allow(backend).to receive(:fetch_remote_translation).with('fr', 'hello')
                                                           .and_return('Bonjour')
      end

      it 'returns the remote translation' do
        expect(backend.translate('fr', 'hello')).to eq('Bonjour')
      end
    end

    context 'when the translation key is not available' do
      it 'returns nil' do
        expect(backend.translate(:en, 'unknown')).to be_nil
      end
    end
  end
end
