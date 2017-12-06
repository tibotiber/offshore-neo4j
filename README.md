# Neo4j docker images with ICIJ offshore leaks

## Use it locally

Build a local image from the github repository:

```
docker build -t offshore-neo4j github.com/tibotiber/offshore-neo4j/
```

Spin off a container using the built image:

```
docker run -p 80:7474 -p 443:7473 -p 7687:7687 -v $HOME/neo4j/data:/data -v $HOME/neo4j/logs:/logs offshore-neo4j
```

Note that this maps to port 80 and 443 of the host for HTTP(s), as well as port
7687 (default) for bolt to run cypher queries. It also syncs the database and
logs to `$HOME/neo4j` on the host. Feel free to change these based on your
use-case.

## On AWS

I built this to run on EC2 instances, I recommend a `m4.xlarge` at least at the
start to build the indexes. Feel free to lower the specs afterwards to save cost
(`t2.small`?).

Security group ports to open:

* SSH 22
* HTTP 80
* HTTPS 443
* BOLT 7687

Feel free to change the exposed ports in the security group and the `docker run`
command.

### Setup

SSH into the instance and install docker:

```
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
```

Then exit and ssh back into it.

Install git to pull the docker image from github:

```
sudo yum install git
```

Refer to the local install commands.
