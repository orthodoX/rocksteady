# frozen_string_literal: true

require 'forwardable'

module RocksteadyTheme
  ThemeConfig = Struct.new(:label, :colour_theme) do
    def warning?
      'warning' == colour_theme
    end

    def application_name
      label.present? ? "Rocksteady (#{label})" : 'Rocksteady'
    end

    def header_html_classes
      warning? ? %w(navbar-dark bg-primary) : %w(navbar-dark bg-dark)
    end

    def deploy_button_html_classes
      warning? ? %w(btn-warning) : %w(btn-success)
    end

    def deploy_button_label
      label.present? ? "Deploy selected image to #{label}" : 'Deploy selected image'
    end
  end

  extend Forwardable

  def_delegators :theme_config, :application_name, :header_html_classes,
                 :deploy_button_html_classes, :deploy_button_label

  class << self
    attr_reader :theme_config

    def parse_config(value)
      conf = JSON.parse(value).with_indifferent_access
      ThemeConfig.new(conf[:label], conf[:colour_theme])
    rescue JSON::ParserError
      ThemeConfig.new
    end
  end

  @theme_config = parse_config(ENV['ROCKSTEADY_THEME'] || '')

  def deploy_button_props
    { html_classes: deploy_button_html_classes, label: deploy_button_label }
  end

  def theme_config
    RocksteadyTheme.theme_config
  end
end
