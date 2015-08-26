[![dockeri.co](http://dockeri.co/image/minicodemonkey/rpi-hjem)](https://registry.hub.docker.com/u/minicodemonkey/rpi-hjem/)

Raspberry Pi docker image for the "hjem" project.

## Build Details
- [Source Project Page](https://github.com/hjem)
- [Source Repository](https://github.com/hjem/hjem-rasp-berry-pi)
- [Dockerfile](https://github.com/hjem/hjem-rasp-berry-pi/blob/master/Dockerfile)
- [DockerHub](https://registry.hub.docker.com/u/minicodemonkey/rpi-hjem/)

## How to use this image

First, make sure to have docker set up on your Raspberry Pi. We recomnend the [hypriot](http://blog.hypriot.com/) (Raspbian-based) Raspberry Pi SD Card image.

### Start a hjem instance

Starting a hjem instance is simple:

	docker run --name my-hjem -e "NEST_THERMOSTAT_EMAIL=mail@example.com" -e "NEST_THERMOSTAT_PASSWORD=12345" -p 80:80 -d minicodemonkey/rpi-hjem

This will launch a new hjem instance listening on port `80` configured for a Nest thermostat. For a list of all environment variables that are available, see [.env.example](https://github.com/hjem/hjem/blob/master/.env.example) in the main hjem project.

## Build the Docker Image
Run all the commands from within the project root directory.

```bash
make build
```


### Push the Docker Image to the Docker Hub
* First use a `docker login` with username, password and email address
* Second push the Docker Image to the official Docker Hub

```bash
make push
```

## Acknowledgements

This image is heavily based off of [hypriot/rpi-mysql](https://github.com/hypriot/rpi-mysql) and the [offical docker php image](https://github.com/docker-library/php/tree/master/5.6/fpm). Thank you so much for your efforts that made this image significantly easier to build.