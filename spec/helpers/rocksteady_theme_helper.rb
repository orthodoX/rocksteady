# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RocksteadyTheme do
  let(:theme_class) { described_class::ThemeConfig }

  let(:theme) { described_class.parse_config(theme_options.to_json) }
  let(:theme_options) { {} }

  describe 'parse_config' do
    context 'with invalid JSON' do
      it 'returns the default ThemeConfig' do
        expect(described_class.parse_config('')).to be_a(theme_class)
      end
    end
  end

  describe 'application_name' do
    context 'with custom config' do
      let(:theme_options) { { label: 'some label' } }

      it 'is Rocksteady (some label)' do
        expect(theme.application_name).to eq('Rocksteady (some label)')
      end
    end

    context 'with default config' do
      it 'is Rocksteady' do
        expect(theme.application_name).to eq('Rocksteady')
      end
    end
  end

  describe 'header_html_classes' do
    context 'with warning config' do
      let(:theme_options) { { colour_theme: 'warning' } }

      it 'includes primary background' do
        expect(theme.header_html_classes).to eq(%w(navbar-dark bg-primary))
      end
    end

    context 'with default config' do
      it 'includes dark background' do
        expect(theme.header_html_classes).to eq(%w(navbar-dark bg-dark))
      end
    end
  end

  describe 'deploy_button_html_classes' do
    context 'with warning config' do
      let(:theme_options) { { colour_theme: 'warning' } }

      it 'is a warning button' do
        expect(theme.deploy_button_html_classes).to eq(%w(btn-warning))
      end
    end

    context 'with default config' do
      it 'is a success button' do
        expect(theme.deploy_button_html_classes).to eq(%w(btn-success))
      end
    end
  end

  describe 'deploy_button_label' do
    context 'with custom config' do
      let(:theme_options) { { label: 'QA' } }

      it 'includes the custom label' do
        expect(theme.deploy_button_label).to eq('Deploy selected image to QA')
      end
    end

    context 'with default config' do
      it 'is the plain phrase' do
        expect(theme.deploy_button_label).to eq('Deploy selected image')
      end
    end
  end
end
