job "very-important-application" {
  datacenters = ["home"]
	type = "service"

    update {
        stagger = "10s"
        max_parallel = 1
    }

	group "web" {
		count = 1

		restart {
			attempts = 3
			delay = "1m"
			interval = "5m"
			mode = "delay"
		}

		constraint {
			attribute = "${attr.kernel.name}"
			value = "linux"
		}

		constraint {
			operator  = "distinct_hosts"
			value     = "true"
		}

		network {
			port "http" { 
				to     = "80"
				static = "8080" 
				}
		}

		task "nginx" {
			driver = "docker"

			config {
				image  = "nginx:stable"
				ports  = ["http"]
				volumes = [
					"local/app:/usr/share/nginx/html/",
					"local/conf.d/default.conf:/etc/nginx/conf.d/default.conf"
				]
			}

			env {
				TZ			= "Europe/Moscow"
			}

			artifact {
				source      = "https://raw.githubusercontent.com/danilabar/wonder_app/refs/heads/main/main_img.jpg"
				destination = "local/app/"
				}

			template {
				destination  = "local/app/index.html"
				change_mode  = "restart"
				data = <<EOH
<!DOCTYPE html>
<html>
  <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
<head>
<title>Проектная работа в Otus</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Проектная работа в Otus по курсу Observability</h1>
<img src="main_img.jpg" name="Otus" align="center" width="600" height="531"  border="0"/>
<p>Тестовое приложение.</p>
</body>
</html>
EOH
			}

			template {
				destination = "local/conf.d/default.conf"
				change_mode  = "restart"
				data = <<EOH
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location /server-status {
        stub_status on;
		access_log off;
    }
}
EOH
			}

			resources {
				cpu    = 150
				memory = 64
				network {
					mbits = 10
				}
			}

			service {
				port = "http"
                tags = [
                	"application"
                ]
			}
		}
	}
}