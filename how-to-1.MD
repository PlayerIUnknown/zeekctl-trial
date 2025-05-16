Solve the SSH issue among manager-worker configuration:
---

# ✅ **PART 1: Fool-Proof Setup (Steps + Commands + Where to Run)**

This guide assumes you're using Linux or WSL with Docker installed.

---

## 🔁 STEP 0: Clean Start (Optional)

If needed:

```bash
docker-compose down -v
rm -rf zeek-cluster/
```

---

## 📁 STEP 1: Create Project Structure

> **Run on your host (terminal):**

```bash
mkdir zeek-cluster && cd zeek-cluster
mkdir zeek
touch docker-compose.yml
touch zeek/zeekctl.cfg zeek/node.cfg zeek/networks.cfg zeek/local.zeek
```

---

## 🐳 STEP 2: Write Config Files (covered in Part 2)

---

## 🧰 STEP 3: Start Cluster

> **On host:**

```bash
docker-compose up -d
```

---

## 🛠️ STEP 4: Install Requirements in All Containers

### 🔧 Inside Each Worker (`zeek-worker1`, `zeek-worker2`)

```bash
docker exec -it zeek-worker1 bash
apt update && apt install -y openssh-server rsync
mkdir -p /var/run/sshd
echo 'root:password' | chpasswd
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
/usr/sbin/sshd
```

Repeat inside `zeek-worker2`.

---

### 🔧 Inside Manager (`zeek-manager`)

```bash
docker exec -it zeek-manager bash
apt update && apt install -y openssh-server openssh-client net-tools iproute2 rsync
mkdir -p /var/run/sshd
echo 'root:password' | chpasswd
/usr/sbin/sshd
```

---

## 🔐 STEP 5: SSH Setup from Manager to Workers

> **Inside manager container:**

```bash
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""
```

---

### 💣 Important: Clean `known_hosts` for fresh IPs

```bash
ssh-keygen -R zeek-worker1
ssh-keygen -R zeek-worker2
ssh-keygen -R 172.21.0.2
ssh-keygen -R 172.21.0.4
rm -f ~/.ssh/known_hosts
```

---

### 🧾 Add updated host/IP keys to known\_hosts

```bash
ssh-keyscan -H zeek-worker1 >> ~/.ssh/known_hosts
ssh-keyscan -H zeek-worker2 >> ~/.ssh/known_hosts
ssh-keyscan -H 172.21.0.2 >> ~/.ssh/known_hosts
ssh-keyscan -H 172.21.0.4 >> ~/.ssh/known_hosts
```

---

### 🔁 Copy SSH keys to both workers

```bash
ssh-copy-id root@zeek-worker1
ssh-copy-id root@zeek-worker2
```

---

## 🚀 STEP 6: Deploy Zeek Cluster

> Inside manager:

```bash
cd /usr/local/zeek
zeekctl
deploy
status
```

Expected output:

```
manager     manager  zeek-manager   running
proxy       proxy    zeek-manager   running
worker1     worker   zeek-worker1   running
worker2     worker   zeek-worker2   running
```

---

## 📈 STEP 7: Relay Traffic Using `tcpreplay` (on host)

1. Install:

```bash
sudo apt install -y tcpreplay
```

2. Get a `.pcap` file:

```bash
wget https://www.netresec.com/files/MultiProtocolCapture1.pcap
```

3. Get the Docker bridge name:

```bash
docker network ls
```

Look for something like `zeek-cluster_zeeknet`, then run:

```bash
docker network inspect zeek-cluster_zeeknet | grep -i gateway
```

Assume bridge is `br-xxxx`.

4. Replay traffic:

```bash
sudo tcpreplay --intf1=br-xxxx MultiProtocolCapture1.pcap
```

---

## 🪵 STEP 8: View Logs by Worker

> Inside manager:

```bash
cd /usr/local/zeek/logs/current
ls
```

If you enabled:

```zeek
redef Log::default_writer = Log::WRITER_PER_WORKER;
```

Then:

```bash
cat conn.zeek-worker1.log | less
cat conn.zeek-worker2.log | less
```

---

## 📌 Done!

Type **`Next`** and I’ll now generate:

* `docker-compose.yml`
* All config files
* Full directory structure

so you can set it up instantly.
