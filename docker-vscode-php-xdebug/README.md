Debug PHP applications running on docker with vscode
====================================================

[Detailed tutorial here.](https://baptiste.bouchereau.pro/tutorial/debug-php-application-running-on-docker-with-vscode/)

Usage
-----

Run

```bash
git clone https://github.com/Ovski4/tutorials.git
cd docker-vscode-php-xdebug
```

Edit the **php.ini** with your internal host ip. On a ubuntu laptop, running `hostname -I | awk '{print $1}'` on the command line prints it. 

Then run  `docker-compose up -d`.

In vscode install the **PHP Debug** extension by Felix Becker. Then select the `debug` tab, then click `Add Configuration`.. and select the `PHP` environment. This will open the `launch.json` file. Erase its content with the following:

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9000,
            "pathMappings": {
                "/var/www/html/": "${workspaceRoot}"
            }
        }
    ]
}
```

Add a breakpoint in **index.php** and hit **Listen for XDebug**. Browse [http://localhost:8080/](http://localhost:8080/).
