# docker-snort

Snort in Docker for Network Functions Virtualization (NFV)

The Snort Version 2.9.7.3

### Docker Usage
You may need to run as `sudo`
Attach the snort in container to have full access to the network

```
docker run -it --rm --net=host linton/docker-snort /bin/bash
```

Or you may need to add --cap-add=NET_ADMIN or --privileged (unsafe)

```
docker run -it --rm --net=host --cap-add=NET_ADMIN linton/docker-snort /bin/bash
```


### Snort Usage

For testing it's work. Add this rule in the file at `/etc/snort/rules/local.rules`

```
alert icmp any any -> any any (msg:"Pinging...";sid:1000004;)
```

Running Snort and alerts to the console (screen).

```
snort -i eth0 -c /etc/snort/etc/snort.conf -A console
```

Ping in the container then the alert message will show on the console

```
ping 8.8.8.8
```
