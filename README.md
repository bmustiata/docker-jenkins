# docker-jenkins

BlueOcean UI Jenkins2 instance that has docker installed as well. For pipeline centric builds.
With git/mercurial/subversion support.

I try to keep it as much as possible up to date.

Currently this is built against Jenkins `2.121.1`.

This is available on Docker hub as `bmst/jenkins2`, or `bmst/jenkins2:blueocean` that also has the blueocean built in.

https://hub.docker.com/r/bmst/jenkins2/

This instance also installs some plugins that there is a high chance you'll need, or find useful, see the dockerfile for the full list.

## How to Run It

### without blueocean

```sh
docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /your/place/for/jenkins_home:/var/jenkins_home \
    -p 8080:8080 \
    --name jenkins \
    bmst/jenkins2
```

### with blueocean

```sh
docker run -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /your/place/for/jenkins_home:/var/jenkins_home \
    -p 8080:8080 \
    --name jenkins \
    bmst/jenkins2:blueocean
```

## How to Update It

Update is not as straightforward, since it might happen that some old plugins have different configurations that are not backwards compatible. This is why I recommend you name you instance and just do regular jenkins upgrades from its interface. The configuration files are available into where you mounted the `/var/jenkins_home` volume from the container.

What I generally do to stick to the newest version also on the docker images: I just create a new conainer with the volumes from the old one, and remove the plugins from the old instance, since they are unpacked in the volume.

```text
$ docker pull bmst/jenkins2
$ docker rename jenkins jenkins_old
$ docker stop jenkins_old
$ docker create \
    -p 8080:8080 \
    --name jenkins \
    --volumes-from=jenkins_old \
    bmst/jenkins2
$ docker run --rm -it --volumes-from jenkins ubuntu
root@68bf16fbcfde:/# cd /var/jenkins_home/plugins/
root@68bf16fbcfde:/var/jenkins_home/plugins# rm *
root@68bf16fbcfde:/var/jenkins_home/plugins# exit
$ docker rm jenkins_old
```

