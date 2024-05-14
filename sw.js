// No rights reserved.

const cacheName = "SW-CACHE";

self.addEventListener('install', (e) => {
    e.waitUntil(
        caches
        .open(cacheName)
        .then(cache => cache.addAll("/"))
        .then(() => self.skipWaiting()));
});

self.addEventListener('message', (e) => {
    e.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cache => {
                    if (cache !== cacheName) {
                        return caches.delete(cache);
                    }
                })
            )
        })
    )
});

self.addEventListener('fetch', (e) => {
    e.respondWith(fetch(e.request).catch(() => caches.match(e.request)))l
});
