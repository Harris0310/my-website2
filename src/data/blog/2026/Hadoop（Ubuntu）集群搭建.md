---
author: C Y
pubDatetime: 2026-01-31T12:00:00Z
title: Hadoop 集群搭建(Ubuntu)
description: "Ubuntu 环境下 Hadoop 分布式集群完整搭建教程"
tags:
  - Hadoop
  - 大数据
  - 集群搭建
  - Ubuntu
---

# Hadoop 集群搭建(Ubuntu)完整教程

本文档详细记录在 Ubuntu 系统上搭建 Hadoop 分布式集群的完整步骤,包括环境准备、网络配置、SSH 免密配置、Hadoop 安装配置及集群验证。

## 集群规划

- **master**: 192.168.32.131 (NameNode + ResourceManager + SecondaryNameNode)
- **node1**: 192.168.32.132 (DataNode + NodeManager)
- **node2**: 192.168.32.133 (DataNode + NodeManager)

---

## 一、基础环境配置(所有节点)

### 1.1 安装中文语言包

```bash
sudo apt update
sudo apt install language-pack-zh-hans language-pack-zh-hans-base
sudo update-locale LANG=zh_CN.UTF-8
```

### 1.2 修改主机名

在 master 节点执行:
```bash
sudo hostnamectl set-hostname master
```

在 node1 节点执行:
```bash
sudo hostnamectl set-hostname node1
```

在 node2 节点执行:
```bash
sudo hostnamectl set-hostname node2
```

### 1.3 配置网络静态 IP(所有节点)

编辑网络配置文件:
```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

配置内容示例(master 节点):
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      dhcp6: no
      addresses: [192.168.32.131/24]
      routes:
        - to: default
          via: 192.168.32.2
      nameservers:
        addresses: [223.5.5.5, 114.114.114.114, 8.8.8.8]
```

应用网络配置:
```bash
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo netplan apply
sudo systemctl restart systemd-networkd
```

> **注意**: node1 和 node2 的 IP 地址需分别修改为 192.168.32.132 和 192.168.32.133

### 1.4 配置 hosts 文件(所有节点)

编辑 hosts 文件:
```bash
sudo nano /etc/hosts
```

添加以下内容(所有节点一致):
```text
192.168.32.131 master
192.168.32.132 node1
192.168.32.133 node2
```

或使用命令直接添加:
```bash
cat <<EOF | sudo tee -a /etc/hosts
192.168.32.131 master
192.168.32.132 node1
192.168.32.133 node2
EOF
```

### 1.5 更换软件源为国内镜像(所有节点)

备份原源文件:
```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
```

使用阿里云镜像:
```bash
sudo tee /etc/apt/sources.list <<'EOF'
deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
EOF
```

或使用清华镜像:
```bash
sudo tee /etc/apt/sources.list <<'EOF'
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ jammy-security main restricted universe multiverse
EOF
```

更新软件包索引:
```bash
sudo apt update
```

---

## 二、安装 Java 环境(所有节点)

```bash
sudo apt update
sudo apt install -y openjdk-11-jdk
java -version
javac -version
ls /usr/lib/jvm/
```

记录 Java 安装路径,后续配置环境变量时使用:
```bash
ls /usr/lib/jvm/
# 输出示例: java-11-openjdk-amd64
```

---

## 三、安装 Hadoop(master 节点)

### 3.1 下载 Hadoop

```bash
cd ~
# 使用清华镜像下载 Hadoop 3.3.6
wget -c https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

### 3.2 解压并安装

```bash
tar -xzf hadoop-3.3.6.tar.gz
sudo mv hadoop-3.3.6 /usr/local/hadoop
sudo chown -R cy:cy /usr/local/hadoop
```

> **注意**: 将 `cy` 替换为你的实际用户名

### 3.3 配置环境变量(所有节点)

编辑用户环境变量文件:
```bash
nano ~/.bashrc
```

在文件末尾添加:
```bash
# Hadoop Environment Variables
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

使环境变量生效:
```bash
source ~/.bashrc
```

**Rocky Linux 系统环境变量参考**:
```bash
export HADOOP_HOME=/opt/module/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
```

---

## 四、配置 SSH 免密登录

### 4.1 配置免密 sudo(所有节点)

将用户加入 sudo 组:
```bash
sudo usermod -aG sudo cy
```

编辑 sudoers 文件:
```bash
sudo visudo
```

在文件末尾添加(免密执行 sudo):
```text
cy ALL=(ALL) NOPASSWD: ALL
```

### 4.2 生成密钥对(master 节点)

```bash
ssh-keygen -t rsa
# 一路回车使用默认配置
```

### 4.3 分发公钥到各节点(master 节点)

```bash
ssh-copy-id cy@master
ssh-copy-id cy@node1
ssh-copy-id cy@node2
```

### 4.4 验证免密登录(master 节点)

```bash
for host in master node1 node2; do
    ssh $host "hostname; java -version"
done
```

### 4.5 手动配置公钥(备选方案)

如果 `ssh-copy-id` 失败,可手动复制公钥:

在 master 节点查看公钥:
```bash
cat ~/.ssh/id_rsa.pub
```

在 node1 和 node2 节点执行:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '你的公钥内容' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

示例:
```bash
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... cy@master' >> ~/.ssh/authorized_keys
```

---

## 五、配置 Hadoop 核心文件(仅在 master 节点)

进入配置目录:
```bash
cd /usr/local/hadoop/etc/hadoop/
```

### 5.1 配置 core-site.xml

```bash
nano core-site.xml
```

配置内容:
```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://master:9000</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/home/cy/hadoop_data/tmp</value>
    </property>
</configuration>
```

### 5.2 配置 hdfs-site.xml

```bash
nano hdfs-site.xml
```

配置内容:
```xml
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${hadoop.tmp.dir}/dfs/name</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file://${hadoop.tmp.dir}/dfs/data</value>
    </property>
</configuration>
```

### 5.3 配置 mapred-site.xml

```bash
nano mapred-site.xml
```

配置内容:
```xml
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
```

### 5.4 配置 yarn-site.xml

```bash
nano yarn-site.xml
```

配置内容:
```xml
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>master</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ</value>
    </property>
</configuration>
```

### 5.5 配置 workers 文件

```bash
nano workers
```

删除 localhost,添加 worker 节点:
```text
node1
node2
```

### 5.6 配置 hadoop-env.sh

```bash
nano hadoop-env.sh
```

找到并取消注释或添加:
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
```

---

## 六、分发 Hadoop 到其他节点(master 节点)

使用 rsync 同步配置到 node1 和 node2:
```bash
cd /usr/local
rsync -avz --rsync-path='sudo rsync' /usr/local/hadoop/ cy@node1:/usr/local/hadoop/
rsync -avz --rsync-path='sudo rsync' /usr/local/hadoop/ cy@node2:/usr/local/hadoop/
```

> **注意**: 确保 node1 和 node2 已安装相同版本的 Java,且环境变量配置正确

---

## 七、启动 Hadoop 集群

### 7.1 首次启动前格式化 NameNode(仅 master 节点)

```bash
hdfs namenode -format
```

> **警告**: 格式化操作只能执行一次,重复格式化会导致 DataNode 无法正常启动!

### 7.2 启动 HDFS(master 节点)

```bash
start-dfs.sh
```

### 7.3 启动 YARN(master 节点)

```bash
start-yarn.sh
```

### 7.4 停止集群(master 节点)

```bash
# 先停 YARN
stop-yarn.sh
# 再停 HDFS
stop-dfs.sh
```

---

## 八、验证集群状态

### 8.1 使用 jps 命令查看进程

**master 节点应显示**:
```text
NameNode
SecondaryNameNode
ResourceManager
Jps
```

**node1 和 node2 节点应显示**:
```text
DataNode
NodeManager
Jps
```

运行命令:
```bash
jps
```

### 8.2 访问 Web 管理界面

在宿主机浏览器中访问:

**HDFS 管理界面**:
```text
http://192.168.32.131:9870
```

**YARN 资源管理界面**:
```text
http://192.168.32.131:8088
```

---

## 九、测试 Hadoop 集群

### 9.1 创建 HDFS 目录

```bash
hdfs dfs -mkdir -p /user/input
```

### 9.2 上传测试文件

如果有 VMware 共享文件夹,可挂载使用:
```bash
sudo mkdir -p /mnt/windows
sudo vmhgfs-fuse .host:/Ubuntu1 /mnt/windows -o allow_other -o uid=1000
ls /mnt/windows/
```

上传文件到 HDFS:
```bash
hdfs dfs -put /mnt/windows/input.txt /user/input/
```

### 9.3 查看文件

```bash
hdfs dfs -ls /user/input/
```

### 9.4 运行 WordCount 示例程序

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar wordcount /user/input /user/output
```

### 9.5 查看输出结果

```bash
hdfs dfs -ls /user/output
hdfs dfs -cat /user/output/part-r-00000
```

---

## 十、常见问题排查

### 10.1 NameNode 格式化失败

检查 Hadoop 配置文件是否正确:
```bash
hdfs namenode -format
```

### 10.2 DataNode 无法启动

删除 DataNode 数据后重新启动:
```bash
rm -rf /home/cy/hadoop_data/tmp/dfs/data/*
stop-dfs.sh
start-dfs.sh
```

### 10.3 SSH 免密登录失败

检查密钥权限:
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys
```

### 10.4 网络连接问题

检查防火墙和 hosts 配置:
```bash
ping master
ping node1
ping node2
```

### 10.5 查看 Hadoop 日志

日志位置:
```bash
$HADOOP_HOME/logs/
```

查看 NameNode 日志:
```bash
tail -f $HADOOP_HOME/logs/hadoop-*-namenode-*.log
```

查看 DataNode 日志:
```bash
tail -f $HADOOP_HOME/logs/hadoop-*-datanode-*.log
```

---

## 十一、补充说明

### 11.1 VMware 共享文件夹挂载

```bash
sudo mkdir -p /mnt/windows
sudo vmhgfs-fuse .host:/Ubuntu1 /mnt/windows -o allow_other -o nonempty -o uid=1000
ls /mnt/windows/
```

### 11.2 集群启动顺序

1. 格式化 NameNode(仅首次)
2. 启动 HDFS (`start-dfs.sh`)
3. 启动 YARN (`start-yarn.sh`)

### 11.3 集群停止顺序

1. 停止 YARN (`stop-yarn.sh`)
2. 停止 HDFS (`stop-dfs.sh`)

### 11.4 环境变量检查

确保所有节点的环境变量配置正确:
```bash
echo $HADOOP_HOME
echo $JAVA_HOME
hadoop version
```

---

## 十二、参考资源

- Hadoop 官方文档: https://hadoop.apache.org/docs/
- Apache 镜像站: https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/
- Ubuntu 官方文档: https://ubuntu.com/server/docs
