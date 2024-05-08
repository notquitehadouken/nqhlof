// No rights reserved.

const name = "SW-NQH";

self.addEventListener('install', (e) => {
    e.waitUntil(self.skipWaiting());
});

self.addEventListener('message', (e) => {
    if (e.data.type === 'CACHE_URLS') {
        e.waitUntil(
            caches.open(name)
                .then( (cache) => {
                    return cache.addAll(event.data.payload);
                })
        );
    }
});
