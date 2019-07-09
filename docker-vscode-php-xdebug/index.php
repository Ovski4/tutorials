<p>Let's do some math.</p>

<ul>
    <?php
        for ($i = 0; $i < 10; $i++) {
            echo sprintf("<li>%s * 5 = %s</li>", $i, $i*5);
        }
    ?>
</ul>
