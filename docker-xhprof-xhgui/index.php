<p>Let's do some math.</p>

<ul>
    <?php
        define('XHGUI_CONFIG_DIR', '/var/xhgui/config/');
        require_once '/var/xhgui/vendor/perftools/xhgui-collector/external/header.php';

        for ($i = 0; $i < 10; $i++) {
            echo sprintf("<li>%s * 5 = %s</li>", $i, $i*5);
        }
    ?>
</ul>
