<?php

return [
    'save.handler' => 'mongodb',
    'db.host' => 'mongodb://mongo:27017',
    'db.db' => 'xhprof',
    'db.options' => [],
    'profiler.enable' => function() {
        return true;
    },
    'profiler.simple_url' => null,
    'profiler.options' => [],
    'date.format' => 'M jS H:i:s',
    'detail.count' => 6,
    'page.limit' => 25,
];
