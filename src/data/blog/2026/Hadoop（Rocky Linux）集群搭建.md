---
author: C Y
pubDatetime: 2026-01-31T12:00:00Z
title: Hadoop 集群搭建(Rocky Linux)
description: "Rocky Linux 环境下 Hadoop 分布式集群完整搭建教程"
tags:
  - Hadoop
  - 大数据
  - 集群搭建
  - Rocky Linux
---

# Hadoop 集群搭建(Rocky Linux)完整教程

本文档详细记录在 Rocky Linux 系统上搭建 Hadoop 分布式集群的完整步骤,包括环境准备、网络配置、SSH 免密配置、Hadoop 安装配置及集群验证。

## 集群规划

- **master**: 192.168.32.131 (NameNode + ResourceManager + SecondaryNameNode)
- **node1**: 192.168.32.132 (DataNode + NodeManager)
- **node2**: 192.168.32.133 (DataNode + NodeManager)

---

## 一、基础环境配置(所有节点)

### 1.1 设置主机名

**master 节点**:
```bash
sudo hostnamectl set-hostname master
```

**node1 节点**:
```bash
sudo hostnamectl set-hostname node1
```

**node2 节点**:
```bash
sudo hostnamectl set-hostname node2
```

### 1.2 配置静态 IP(所有节点)

使用 nmcli 命令配置网络:

**master 节点 (192.168.32.131)**:
```bash
sudo nmcli con mod ens33 ipv4.addresses 192.168.32.131/24
sudo nmcli con mod ens33 ipv4.gateway 192.168.32.2
sudo nmcli con mod ens33 ipv4.dns "223.5.5.5,114.114.114.114"
sudo nmcli con mod ens33 ipv4.method manual
sudo nmcli con up ens33
```

**node1 节点 (192.168.32.132)**:
```bash
sudo nmcli con mod ens33 ipv4.addresses 192.168.32.132/24
sudo nmcli con mod ens33 ipv4.gateway 192.168.32.2
sudo nmcli con mod ens33 ipv4.dns "223.5.5.5,114.114.114.114"
sudo nmcli con mod ens33 ipv4.method manual
sudo nmcli con up ens33
```

**node2 节点 (192.168.32.133)**:
```bash
sudo nmcli con mod ens33 ipv4.addresses 192.168.32.133/24
sudo nmcli con mod ens33 ipv4.gateway 192.168.32.2
sudo nmcli con mod ens33 ipv4.dns "223.5.5.5,114.114.114.114"
sudo nmcli con mod ens33 ipv4.method manual
sudo nmcli con up ens33
```

> **注意**: 
> - `ens33` 是网卡名称,根据实际情况调整
> - `192.168.32.2` 是网关地址,根据实际网络环境修改

### 1.3 配置 hosts 文件(所有节点)

添加主机名映射(所有节点执行相同命令):
```bash
cat <<EOF | sudo tee -a /etc/hosts
192.168.32.131 master
192.168.32.132 node1
192.168.32.133 node2
EOF
```

### 1.4 关闭防火墙(所有节点)

```bash
# 停止防火墙服务
sudo systemctl stop firewalld

# 禁止防火墙开机自启
sudo systemctl disable firewalld
```

### 1.5 关闭 SELinux(所有节点)

临时关闭 SELinux:
```bash
sudo setenforce 0
```

永久关闭 SELinux:
```bash
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

验证 SELinux 状态:
```bash
getenforce
# 应输出: Disabled
```

> **重要**: SELinux 必须关闭,否则会影响 Hadoop 集群的正常运行

---

## 二、安装 Java 环境(所有节点)

```bash
# 安装 OpenJDK 11
sudo dnf install -y java-11-openjdk-devel

# 验证安装
java -version

# 查看 Java 安装路径
ls /usr/lib/jvm/
# 输出示例: java-11-openjdk
```

---

## 三、安装 Hadoop(master 节点)

### 3.1 创建 Hadoop 安装目录

```bash
# 创建模块目录
sudo mkdir -p /opt/module

# 修改目录所有者为当前用户
sudo chown cy:cy /opt/module
```

> **注意**: 将 `cy` 替换为你的实际用户名

### 3.2 下载 Hadoop

```bash
cd /opt/module
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

### 3.3 解压并重命名

```bash
# 解压 Hadoop
tar -xzf hadoop-3.3.6.tar.gz

# 重命名目录
mv hadoop-3.3.6 hadoop
```

### 3.4 配置环境变量(所有节点)

编辑用户环境变量文件:
```bash
vim ~/.bashrc
```

在文件末尾添加:
```bash
# Hadoop Environment Variables
export HADOOP_HOME=/opt/module/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
```

使环境变量生效:
```bash
source ~/.bashrc
```

---

## 四、配置 SSH 免密登录

### 4.1 生成密钥对(master 节点)

```bash
ssh-keygen -t rsa
# 一路回车使用默认配置
```

### 4.2 分发公钥到各节点(master 节点)

```bash
ssh-copy-id master
ssh-copy-id node1
ssh-copy-id node2
```

> **注意**: 首次连接时需要输入各节点密码

### 4.3 验证免密登录(master 节点)

```bash
for host in master node1 node2; do
    ssh $host "hostname"
done
```

如果配置成功,应该可以直接登录各节点,无需输入密码。

---

## 五、配置 Hadoop 核心文件(仅在 master 节点)

进入配置目录:
```bash
cd /opt/module/hadoop/etc/hadoop/
```

### 5.1 配置 core-site.xml

```bash
vim core-site.xml
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
        <value>/opt/module/hadoop/data/tmp</value>
    </property>
    <property>
        <name>hadoop.http.staticuser.user</name>
        <value>cy</value>
    </property>
</configuration>
```

> **注意**: `hadoop.http.staticuser.user` 设置为你的实际用户名

### 5.2 配置 hdfs-site.xml

```bash
vim hdfs-site.xml
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

### 5.3 配置 yarn-site.xml

```bash
vim yarn-site.xml
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

### 5.4 配置 mapred-site.xml

```bash
vim mapred-site.xml
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

### 5.5 配置 workers 文件

```bash
vim workers
```

删除 localhost,添加 worker 节点:
```text
node1
node2
```

### 5.6 配置 hadoop-env.sh

```bash
vim hadoop-env.sh
```

找到并取消注释或添加:
```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
```

---

## 六、准备节点并分发 Hadoop

### 6.1 在 node1 和 node2 准备目录

在 **node1** 和 **node2** 节点分别执行:
```bash
# 清空旧目录(如果有)
sudo rm -rf /opt/module/*

# 创建 Hadoop 目录
sudo mkdir -p /opt/module/hadoop

# 修改目录所有者
sudo chown -R cy:cy /opt/module
```

### 6.2 分发 Hadoop 到其他节点(master 节点)

在 **master** 节点执行:

**方式一**: 精确同步(推荐)
```bash
# 注意:hadoop 后面没有斜杠!
for host in node1 node2; do
    echo "正在精确同步到 $host..."
    rsync -avz /opt/module/hadoop cy@$host:/opt/module/
done
```

**方式二**: 同步目录内容
```bash
for host in node1 node2; do
    rsync -avz /opt/module/hadoop/ cy@$host:/opt/module/
done
```

> **注意**: 
> - 方式一会创建 `/opt/module/hadoop` 目录并复制内容
> - 方式二要求目标目录已存在,仅同步目录内容
> - 确保各节点环境变量配置正确且已生效

---

## 七、启动 Hadoop 集群

### 7.1 首次启动前格式化 NameNode(仅 master 节点)

```bash
hdfs namenode -format
```

> **警告**: 
> - 格式化操作只能执行一次!
> - 重复格式化会导致 DataNode 无法正常启动
> - 如果需要重新格式化,先清理所有节点的数据目录

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

### 7.5 清理数据目录(需要重新格式化时)

如果需要重新格式化 NameNode,需先清理所有节点的数据目录:

在 **master** 节点:
```bash
rm -rf /opt/module/hadoop/data/tmp/*
```

在 **node1** 和 **node2** 节点:
```bash
rm -rf /opt/module/hadoop/data/tmp/*
```

---

## 八、验证集群状态

### 8.1 使用 jps 命令查看进程

在 **master** 节点执行:
```bash
jps
```

应显示:
```text
NameNode
SecondaryNameNode
ResourceManager
Jps
```

在 **node1** 和 **node2** 节点执行:
```bash
jps
```

应显示:
```text
DataNode
NodeManager
Jps
```

### 8.2 使用 HDFS 命令查看集群状态

在 **master** 节点执行:
```bash
hdfs dfsadmin -report
```

该命令会显示:
- 集群配置信息
- Live Nodes 数量(应显示 2)
- 每个 DataNode 的容量和使用情况

### 8.3 访问 Web 管理界面

在宿主机浏览器中访问:

**HDFS 管理界面**:
```text
http://192.168.32.131:9870
```

**YARN 资源管理界面**:
```text
http://192.168.32.131:8088
```

> **注意**: 确保宿主机可以访问虚拟机的网络,或者直接在虚拟机内浏览器访问

---

## 九、测试 Hadoop 集群

### 9.1 创建 HDFS 目录

```bash
hdfs dfs -mkdir -p /user/input
```

### 9.2 上传测试文件

创建测试文件:
```bash
echo "Hello Hadoop" > /tmp/test.txt
```

上传到 HDFS:
```bash
hdfs dfs -put /tmp/test.txt /user/input/
```

### 9.3 查看文件

```bash
hdfs dfs -ls /user/input/
hdfs dfs -cat /user/input/test.txt
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

检查 `/opt/module/hadoop/etc/hadoop/` 下的配置文件

### 10.2 DataNode 无法启动

删除 DataNode 数据后重新启动:

在 **master** 节点:
```bash
rm -rf /opt/module/hadoop/data/tmp/*
```

在 **node1** 和 **node2** 节点:
```bash
rm -rf /opt/module/hadoop/data/tmp/*
```

重启集群:
```bash
stop-dfs.sh
hdfs namenode -format
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

检查 SELinux 状态:
```bash
getenforce
# 应输出: Disabled
```

### 10.4 网络连接问题

检查防火墙状态:
```bash
sudo systemctl status firewalld
```

检查 SELinux 状态:
```bash
getenforce
```

测试网络连通性:
```bash
ping master
ping node1
ping node2
```

### 10.5 查看 Hadoop 日志

日志位置:
```bash
/opt/module/hadoop/logs/
```

查看 NameNode 日志:
```bash
tail -f /opt/module/hadoop/logs/hadoop-*-namenode-*.log
```

查看 DataNode 日志:
```bash
tail -f /opt/module/hadoop/logs/hadoop-*-datanode-*.log
```

查看 ResourceManager 日志:
```bash
tail -f /opt/module/hadoop/logs/yarn-*-resourcemanager-*.log
```

查看 NodeManager 日志:
```bash
tail -f /opt/module/hadoop/logs/yarn-*-nodemanager-*.log
```

### 10.6 权限问题

检查 Hadoop 目录权限:
```bash
ls -ld /opt/module
ls -ld /opt/module/hadoop
```

确保所有者正确:
```bash
sudo chown -R cy:cy /opt/module
```

### 10.7 端口被占用

检查端口占用情况:
```bash
sudo netstat -tlnp | grep 9000
sudo netstat -tlnp | grep 9870
sudo netstat -tlnp | grep 8088
```

### 10.8 Java 版本不兼容

验证 Java 版本:
```bash
java -version
# 应输出: openjdk version "11.x.x"
```

检查 Java 安装路径:
```bash
ls /usr/lib/jvm/
```

---

## 十一、补充说明

### 11.1 Rocky Linux 与 Ubuntu 的主要区别

| 配置项 | Ubuntu | Rocky Linux |
|--------|--------|-------------|
| 网络配置 | netplan | nmcli |
| 软件管理 | apt | dnf/yum |
| 防火墙 | ufw | firewalld |
| SELinux | 无 | 需要关闭 |
| Java 路径 | /usr/lib/jvm/java-11-openjdk-amd64 | /usr/lib/jvm/java-11-openjdk |

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

### 11.5 rsync 同步注意事项

- **方式一**: `rsync -avz /opt/module/hadoop cy@host:/opt/module/`
  - 会创建 `/opt/module/hadoop` 目录
  - 适用于目标目录不存在的情况
  
- **方式二**: `rsync -avz /opt/module/hadoop/ cy@host:/opt/module/`
  - 要求目标目录 `/opt/module/hadoop` 已存在
  - 仅同步目录内容

### 11.6 网络配置说明

Rocky Linux 使用 NetworkManager 管理网络:
```bash
# 查看网络连接
nmcli con show

# 查看当前网络状态
nmcli device status

# 测试网络配置
ping 192.168.32.2
ping 223.5.5.5
```

---

## 十二、参考资源

- Hadoop 官方文档: https://hadoop.apache.org/docs/
- Apache 镜像站: https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/
- Rocky Linux 官方文档: https://docs.rockylinux.org/
- Red Hat SELinux 文档: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/
