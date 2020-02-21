import Turbolinks from 'turbolinks';
Turbolinks.start();

import Rails from 'rails-ujs';
Rails.start();

import bootstrap from 'bootstrap.native';

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('[data-toggle="buttons"]').forEach((button) => new bootstrap.Button(button));
});

import AllocationStatus from 'components/AllocationStatus';
import DeployedImage from 'components/DeployedImage';
import ImageSelector from 'components/ImageSelector';
import NomadStatus from 'components/NomadStatus';
import StatusBadge from 'components/StatusBadge';

import WebpackerReact from 'webpacker-react';
WebpackerReact.setup({ StatusBadge, ImageSelector, NomadStatus, AllocationStatus, DeployedImage });

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

document.addEventListener('turbolinks:load', () => {
  const coll = document.getElementsByClassName('collapsible');
  for (let i = 0; i < coll.length; i++) {
    coll[i].addEventListener('click', (event) => {
      if (event && event.currentTarget) {
        let block = event.currentTarget as Element;
        block.classList.toggle('active');

        let content = block.nextElementSibling as HTMLElement;
        if (content.style.maxHeight) {
          content.style.maxHeight = null;
        } else {
          content.style.maxHeight = content.scrollHeight + "px";
        }
      }
    });
  }
});
