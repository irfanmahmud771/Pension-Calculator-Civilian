const CACHE_NAME = 'pension-civilan-v2';
const APP_SHELL = [
  './',
  './index.html',
  './manifest.webmanifest',
  './assets/icons/icon.svg'
];

const isAppShellAsset = (url) => {
  return url.origin === self.location.origin && (
    url.pathname === '/' ||
    url.pathname.endsWith('/index.html') ||
    url.pathname.endsWith('/manifest.webmanifest') ||
    url.pathname.endsWith('/assets/icons/icon.svg')
  );
};

const isSupabaseRequest = (url) => url.hostname.endsWith('supabase.co');

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((key) => key !== CACHE_NAME)
          .map((key) => caches.delete(key))
      )
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;

  if (request.method !== 'GET') return;

  const requestUrl = new URL(request.url);

  // Never cache Supabase requests. Logs must always be loaded from live server data.
  if (isSupabaseRequest(requestUrl)) {
    event.respondWith(fetch(request));
    return;
  }

  // Cache-first for static app shell so calculator keeps working offline.
  if (isAppShellAsset(requestUrl)) {
    event.respondWith(
      caches.match(request).then((cached) => {
        if (cached) return cached;
        return fetch(request).then((response) => {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, responseClone));
          return response;
        });
      })
    );
    return;
  }

  // Network-first for all other requests; fallback to cache only for same-origin resources.
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (requestUrl.origin === self.location.origin && response && response.ok) {
          const responseClone = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, responseClone));
        }
        return response;
      })
      .catch(async () => {
        if (requestUrl.origin === self.location.origin) {
          const cached = await caches.match(request);
          if (cached) return cached;
        }
        return caches.match('./index.html');
      })
  );
});
