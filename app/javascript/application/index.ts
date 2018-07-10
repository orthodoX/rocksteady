import Turbolinks from 'turbolinks';
Turbolinks.start();

import Rails from 'rails-ujs';
Rails.start();

import hljs from 'highlight.js';

import 'bootstrap.native/dist/bootstrap-native-v4';

document.addEventListener('turbolinks:load', () => {
  document.querySelectorAll('pre code').forEach((block) => hljs.highlightBlock(block));
});

import ImageSelector from 'components/ImageSelector';
import NomadStatus from 'components/NomadStatus';
import StatusBadge from 'components/StatusBadge';

import WebpackerReact from 'webpacker-react';
WebpackerReact.setup({ StatusBadge, ImageSelector, NomadStatus });
