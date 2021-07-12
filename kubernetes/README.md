# Kubernetes Cluster

## Installation

We need a new machine with the following requirements:

- SSH root access.
- Public IPv4 address.
- The domain `kube.master.srk.bz` points to this machine's IP.

Also, in our local machine, we'll need:

- [ASDF Version Manager](https://asdf-vm.com).
- With plugins for [kubectl](https://github.com/Banno/asdf-kubectl.git) and
  [go-jsonnet](https://github.com/sirikon/asdf-go-jsonnet).

SSH into the machine and run:

```bash
curl -sfL https://get.k3s.io | sh -
```

This will install k3s in the machine. Once the command finishes, disconnect
and run:

```bash
./configure-kubectl.sh
```

After that, run this command in a separate terminal and leave it running.
It's a pipe to the cluster's Kubernetes API:

```bash
./pipe.sh
```

Then, getting the running node and pods like this, should work, and everything
should be in `Running` or `Completed` state:

```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

Now we'll add the extra stuff we'll need in the cluster: Cert Manager and the
Dashboard:

```bash
./install-extras.sh
```

After this, list again all the pods and wait until all of them are running.

Next step, generate all the kubernetes definitions for the cluster:

```bash
./gen.sh
```

Following that, we can start by configuring Cert Manager and the Dashboard:

```bash
kubectl apply -f ./defs-gen/cert-manager/ --recursive
kubectl apply -f ./defs-gen/dashboard-user/ --recursive
```

Again, wait for all the pods to be on `Ready` state.

At this point, only the apps remain to be deployed, but we need an extra step.
Make sure all of the domains defined in `./defs/main.jsonnet` are pointing to
the machine. Probably adding a CNAME to `kube.master.srk.bz` is a good idea.

Also, some apps might need configurations and credentials for databases, etc.
Sort that out and create `config.json` file with all the required config. See
in `./defs/main.jsonnet` how the file is being imported.

Once all that is done, deploy the apps:

```bash
./apply-apps.sh
```

## Administration

### Dashboard access

Assuming everything is installed properly, just run:

```bash
./dashboard.sh
```

This script will display the URL to access the Dashboard **and** display
aswell the secret token required for accessing to the dashboard.

## Maintenance

### PostgreSQL backup

Navigate to the mounted disk inside `/mnt`, folder `db`, impersonate as
`postgres` user and run this:

```bash
pg_dumpall > dump.sql
```

### Upgrade k3s

Version upgrades of k3s are performed with the same command to install it:

```bash
curl -sfL https://get.k3s.io | sh -
```

The command will upgrade and restart the k3s service without stopping the
running pods.

### Fix certificate issues

```sh
./gen.sh
cd ./defs-gen/apps/<problematic app>/
kubectl delete -f . --recursive
cd ../../../
./apply-apps.sh

# Wait
# See progress with
kubectl get certificates
kubectl describe certificate xxxxx
```
