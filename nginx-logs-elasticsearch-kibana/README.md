Analyze Nginx logs using Elasticsearch and Kibana
=================================================

[Detailed tutorial here.](https://baptiste.bouchereau.pro/tutorial/analyze-nginx-logs-with-elasticsearch-and-kibana/)

Setup
-----

1. Clone the repo.

```bash
git clone https://github.com/Ovski4/tutorials.git
cd nginx-logs-elasticsearch-kibana
```

2. Run the Nginx, Kibana and elasicsearch containers.

```bash
docker compose up -d
```

3. Check the Nginx logs are present in the right location. Run:

```bash
nginx_container_id=$(docker ps -q --no-trunc --filter "name=nginx-1") && sudo tail -f /var/lib/docker/containers/$nginx_container_id/$nginx_container_id-json.log
```

Then browse [http:localhost:8080/article1.html](http:localhost:8080/article1.html) to confirm the logs are showing up in the command output. If you see "Configure Elastic to get started", the initial setup is not done yet so wait a few more minutes and refresh the page until you see the console.

4. Creates the GeoIp pipeline from the Kibana console at [http://localhost:5601/app/dev_tools#/console/shell](http://localhost:5601/app/dev_tools#/console/shell). Copy & paste, then execute the following command:


```
PUT _ingest/pipeline/geoip-info
{
  "description": "Add geoip info",
  "processors": [
    {
      "geoip": {
        "field": "source.ip",
        "target_field": "source.geo",
        "ignore_missing": true
      }
    }
  ]
}
```

5. Uncomment the filebeat service in the `docker-compose.yml` file and run `docker compose up -d` again.

6. Open and refresh pages at [http://localhost:8080/article1.html](http://localhost:8080/article1.html) and [http://localhost:8080/article1.html](http://localhost:8080/article2.html) to generate some logs.

7. Open the Kibana [Index Management page](http://localhost:5601/app/management/data/index_management/indices), and look at the [Data Streams tab](http://localhost:5601/app/management/data/index_management/data_streams). You should see `filebeat-8.19.9` created from our nginx container logs.

8. Open the Kibana [Data Views page](http://localhost:5601/app/management/kibana/dataViews) and hit the `Create data view` button. Fill in the fields (set the index pattern to `filebeat-*`) and hit "Save data view to Kibana"

9. Finally, open the [Discover page](http://localhost:5601/app/discover). You should see the logs data, nicely parsed in different fields ready to be used to create charts.
