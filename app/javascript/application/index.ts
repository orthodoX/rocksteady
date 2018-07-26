import Turbolinks from 'turbolinks';
Turbolinks.start();

import Rails from 'rails-ujs';
Rails.start();

import bootstrap from 'bootstrap.native';

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('[data-toggle="buttons"]').forEach((button) => new bootstrap.Button(button));
});

import ImageSelector from 'components/ImageSelector';
import NomadStatus from 'components/NomadStatus';
import StatusBadge from 'components/StatusBadge';

import WebpackerReact from 'webpacker-react';
WebpackerReact.setup({ StatusBadge, ImageSelector, NomadStatus });

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('.auto-deploy-field').forEach((field) => {
    const selectors = Array.from(document.querySelectorAll('.app-image-source-selector input')) as HTMLInputElement[];
    if (!selectors.length) return;

    const ecrSelector = selectors.find((s) => s.value === 'ecr');

    const updater = () => {
      if (ecrSelector && ecrSelector.checked) {
        field.classList.remove('hidden');
      } else {
        field.classList.add('hidden');
      }
    };

    updater();
    selectors.forEach((selector) => selector.addEventListener('click', updater));
  });
});
