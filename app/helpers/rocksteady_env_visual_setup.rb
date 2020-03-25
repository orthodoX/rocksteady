# frozen_string_literal: true

module RocksteadyEnvVisualSetup
  def self.included(base)
    case ENV['ROCKSTEADY_ENV']
    when 'live' then base.include(LiveSetup)
    when 'staging' then base.include(StagingSetup)
    end
  end

  def application_name
    'Rocksteady'
  end

  def header_html_classes
    %w(navbar-dark bg-dark)
  end

  def deploy_button_html_classes
    %w(btn-success)
  end

  def deploy_button_label
    'Deploy selected image'
  end

  def deploy_button_props
    { html_classes: deploy_button_html_classes, label: deploy_button_label }
  end

  module LiveSetup
    def application_name
      'Rocksteady (PRODUCTION)'
    end

    def header_html_classes
      %w(navbar-dark bg-primary)
    end

    def deploy_button_html_classes
      %w(btn-warning)
    end

    def deploy_button_label
      'Deploy selected image to PRODUCTION'
    end
  end

  module StagingSetup
    def application_name
      'Rocksteady (staging)'
    end

    def header_html_classes
      %w(navbar-dark bg-secondary)
    end

    def deploy_button_label
      'Deploy selected image to staging'
    end
  end
end
