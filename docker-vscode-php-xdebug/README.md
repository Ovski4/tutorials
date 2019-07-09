Debug PHP applications running on docker with vscode
====================================================

Usage
-----

Run

```bash
git clone https://github.com/Ovski4/tutorials.git
cd docker-vscode-php-xdebug
docker-compose up -d
```

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

Add a breakpoint in index.php and hit Listen for XDebug. Browse http://localhost:8080/.
