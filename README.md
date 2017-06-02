[![Build Status](https://secure.travis-ci.org/k0nsl/Logbot.png?branch=master)](http://travis-ci.org/k0nsl/Logbot)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/0c06454594834f66b7e7c1e115cdc9f9)](https://www.codacy.com/app/k0nsl/Logbot?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=k0nsl/Logbot&amp;utm_campaign=Badge_Grade)

# About
Logbot is a simple IRC logger with realtime web-based viewer.


# Screenshot
![Logbot screenshot](https://raw.github.com/k0nsl/Logbot/master/screenshot.png)


# How to Deploy
* Use Docker
    1. Install [Docker](https://www.docker.com/)
    2. Run `docker run -d -p 15000:15000 -v /home/k0nsl/logbot:/etc/logbot -e LOGBOT_NICK=genericnondescripguy -e LOGBOT_CHANNELS=#k0nsl,#trinity,#thehax -e LOGBOT_SERVER=ragnarok.k0nsl.org logbot`
    3. Visit [http://localhost:15000](http://localhost:15000)

# Building Docker image manually

* Run the following command
    1. `docker build -t logbot .`
    2. Then `docker-compose up -d` (or use cmd in "How to Deploy")

* Manual installation
    1. Ruby (1.9.3+) and Redis server must be installed
    2. Run `bundle install` to install required Ruby gems
    3. Run `compass compile` to compile Sass files
    4. Fire up your `redis-server`
    5. Specify target channels in `logbot.rb`
    6. Run `foreman start` to launch web server (WEBrick) and Logbot agent
    7. Visit [http://localhost:15000](http://localhost:15000).


# Reverse proxy setup with Caddy

First find the IP of the docker container by issuing `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-id>` and make a note of it.

## Caddy configuration

This is the configuration used for https://genericnondescripguy.k0nsl.org
```
https://genericnondescripguy.k0nsl.org {
root /home/generic01/www
gzip
errors /dev/null
    proxy / 172.19.0.2:15000 {
        websocket
        header_upstream X-Forwarded-Proto {scheme}
        header_upstream X-Forwarded-For {host}
        header_upstream Host {host}
    }
}
````

# How to Contribute

Just hack it and send me pull requests ;)


# License

Licensed under the [MIT license](http://opensource.org/licenses/mit-license.php).

Copyright (c) 2013 Shao-Chung Chen

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.