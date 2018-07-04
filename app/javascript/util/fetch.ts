import _ from 'lodash';

const parseStatus = (response: Response) => {
  if (response.status >= 200 && response.status < 300) {
    return response;
  } else {
    throw new Error(response.statusText);
  }
};

const railsyFetch = (url: string, options?: {[s: string]: any}) => {
  const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
  const csrfToken = csrfMetaTag && csrfMetaTag.getAttribute('content');

  if (!csrfToken) throw new Error('CSRF token not found');

  const opts = {
    credentials: ('same-origin' as 'same-origin'),
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
      'X-Requested-With': 'XMLHttpRequest',
    },
  };

  _.merge(opts, options);

  return fetch(url, opts).then(parseStatus);
};

export default railsyFetch;
