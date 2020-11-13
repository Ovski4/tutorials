<p>Let's do some math.</p>

<ul>
    <?php
        require '/var/xhgui/vendor/autoload.php';
        $config = include '/var/xhgui/config/config.php';
        $profiler = new \Xhgui\Profiler\Profiler($config);
        $profiler->start();

        for ($i = 0; $i < 10; $i++) {
            echo sprintf("<li>%s * 5 = %s</li>", $i, $i*5);
        }
    ?>
</ul>
