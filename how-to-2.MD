# ✅ PART 2: All Code + Directory Structure + IP Check Commands

---

## 📁 Final Directory Structure

```bash
zeek-cluster/
├── docker-compose.yml
└── zeek/
    ├── zeekctl.cfg
    ├── node.cfg
    ├── networks.cfg
    └── local.zeek
```

---

## 📄 1. `docker-compose.yml`

```yaml
version: '3.8'
services:
  manager:
    image: zeek/zeek:latest
    container_name: zeek-manager
    tty: true
    stdin_open: true
    cap_add:
      - NET_ADMIN
      - NET_RAW
    volumes:
      - ./zeek:/usr/local/zeek/etc
      - zeek-logs:/usr/local/zeek/logs
    networks:
      - zeeknet
    command: /bin/bash

  worker1:
    image: zeek/zeek:latest
    container_name: zeek-worker1
    tty: true
    stdin_open: true
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      - zeeknet
    command: /bin/bash

  worker2:
    image: zeek/zeek:latest
    container_name: zeek-worker2
    tty: true
    stdin_open: true
    cap_add:
      - NET_ADMIN
      - NET_RAW
    networks:
      - zeeknet
    command: /bin/bash

volumes:
  zeek-logs:

networks:
  zeeknet:
    driver: bridge
```

---

## 📄 2. `zeek/zeekctl.cfg`

```cfg
MailTo = root@localhost
LogDir = /usr/local/zeek/logs
SpoolDir = /usr/local/zeek/spool
```

---

## 📄 3. `zeek/node.cfg`

```cfg
[manager]
type=manager
host=zeek-manager
interface=eth0

[proxy]
type=proxy
host=zeek-manager
interface=eth0

[worker1]
type=worker
host=zeek-worker1
interface=eth0

[worker2]
type=worker
host=zeek-worker2
interface=eth0
```

---

## 📄 4. `zeek/networks.cfg`

```cfg
192.168.0.0/16 Private
10.0.0.0/8 Internal
```

---

## 📄 5. `zeek/local.zeek`

```zeek
redef Log::default_writer = Log::WRITER_PER_WORKER;
```

This logs each worker's output to files like `conn.zeek-worker1.log`.

---

## 🔍 How to Find Local IPs in Docker

### ✅ Option 1: Inspect Individual Container

```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zeek-manager
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zeek-worker1
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' zeek-worker2
```

---

### ✅ Option 2: List All Running Containers with IPs

```bash
docker ps -q | xargs -n1 docker inspect --format '{{.Name}} => {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

Example output:

```
/zeek-manager => 172.21.0.3
/zeek-worker1 => 172.21.0.2
/zeek-worker2 => 172.21.0.4
```

---

## 🧠 Bonus: SSH Fingerprint Handling Commands

```bash
# Remove old keys
ssh-keygen -R zeek-worker1
ssh-keygen -R 172.21.0.2
rm -f ~/.ssh/known_hosts

# Add current ones
ssh-keyscan -H zeek-worker1 >> ~/.ssh/known_hosts
ssh-keyscan -H 172.21.0.2 >> ~/.ssh/known_hosts
```

---


