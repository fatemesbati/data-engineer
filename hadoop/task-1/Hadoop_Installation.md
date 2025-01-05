
# Hadoop Installation and Configuration on a Single Node Cluster

Based on the [Hadoop Single Node Cluster Setup Documentation](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html), this guide provides a step-by-step procedure to install and configure Hadoop on a single-node cluster. The instructions also include solutions to common issues encountered during the process.

## Prerequisites:
- **Operating System:** Linux distribution (e.g., Ubuntu)
- **Java:** Ensure Java is installed on your system, as Hadoop requires Java 21 or a compatible version.

### Step 1: Install Java
Hadoop depends on Java to function, so the first step is installing Java.

1. **Update your package repository:**
   ```bash
   # For Debian:
   sudo apt-get update

   # For RHEL:
   sudo dnf update
   ```

2. **Install Java 21 (OpenJDK):**
   ```bash
   # For Debian:
   sudo apt-get install openjdk-21-jdk

   # For RHEL:
   sudo dnf install java-21-openjdk
   sudo dnf install java-21-openjdk-devel -y
   
   sudo dnf install java-17-openjdk-devel -y
   
   sudo dnf install java-11-openjdk-devel -y
   
   sudo dnf install java-1.8.0-openjdk-devel -y
   ```

3. **Verify Java installation:**
   ```bash
   java -version
   ```
   This command should output Java version 8.

4. **Set Java environment variables:**
   Open your `.bashrc` file:
   ```bash
   nano ~/.bashrc
   ```
   Add the following lines to set up the Java environment:
   ```bash
   export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
   export PATH=$PATH:$JAVA_HOME/bin
   ```
   Save the file and run:
   ```bash
   source ~/.bashrc
   ```
   If multiple Java versions are installed, you can use the following command to select the default version:
5. if you change it, close your terminal!
   ```bash
   sudo update-alternatives --config java  # For Debian
   sudo alternatives --config java        # For RHEL
   ```

### Step 2: Download and Install Hadoop

1. **Download the latest stable version of Hadoop:**
   ```bash
   wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
   wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.5/hadoop-3.3.5.tar.gz

   ```

2. **Extract the downloaded file:**
   ```bash
   tar -xzvf hadoop-3.3.5.tar.gz
   tar -xzvf apache-hive-3.1.3-bin.tar.gz
   ```

3. **Move the extracted files to `/usr/local/hadoop`:**
   ```bash
   sudo mv hadoop-3.3.5 /usr/local/hadoop
   sudo mv apache-hive-3.1.3-bin /usr/local/hive
   ```

### Step 3: Configure Hadoop Environment Variables

1. Open your `.bashrc` file to add Hadoop environment variables:
   ```bash
   nano ~/.bashrc
   ```

2. Add the following lines to the file:
   ```bash
   export HADOOP_HOME=/usr/local/hadoop
   export HADOOP_INSTALL=$HADOOP_HOME
   export HADOOP_MAPRED_HOME=$HADOOP_HOME
   export HADOOP_COMMON_HOME=$HADOOP_HOME
   export HADOOP_HDFS_HOME=$HADOOP_HOME
   export YARN_HOME=$HADOOP_HOME
   export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
   export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
   export LD_LIBRARY_PATH=$HADOOP_COMMON_LIB_NATIVE_DIR:$LD_LIBRARY_PATH
   export PDSH_RCMD_TYPE=ssh
   ```

3. Save the file and apply the changes:
   ```bash
   source ~/.bashrc
   ```

---

### Step 4: Configure Hadoop Files

Hadoop uses several configuration files located in `$HADOOP_HOME/etc/hadoop`. These files control the behavior of Hadoop daemons and services.

#### 1. core-site.xml
Open the file:
```bash
nano $HADOOP_HOME/etc/hadoop/core-site.xml
```
Add the following content:
```xml
<configuration>
   <property>
      <name>fs.defaultFS</name>
      <value>hdfs://localhost:9000</value>
   </property>
</configuration>
```

#### 2. hdfs-site.xml
Open it:
```bash
nano $HADOOP_HOME/etc/hadoop/hdfs-site.xml
```
Add the following content:
```xml
<configuration>
   <property>
      <name>dfs.replication</name>
      <value>1</value>
   </property>
   <property>
      <name>dfs.namenode.name.dir</name>
      <value>file:///usr/local/hadoop/hdfs/namenode</value>
   </property>
   <property>
      <name>dfs.datanode.data.dir</name>
      <value>file:///usr/local/hadoop/hdfs/datanode</value>
   </property>
</configuration>
```

#### 3. mapred-site.xml
Create the file by copying the template:
```bash
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml
```
Ignore above command if you face any error and just run this:
```bash
nano $HADOOP_HOME/etc/hadoop/mapred-site.xml
```
Add the following:
```xml
<configuration>
   <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
   </property>
</configuration>
```

#### 4. yarn-site.xml
Open the file:
```bash
nano $HADOOP_HOME/etc/hadoop/yarn-site.xml
```
Add the following content:
```xml

<configuration>
   <!-- Site specific YARN configuration properties -->
   <property>
      <name>yarn.nodemanager.aux-services</name>
      <value>mapreduce_shuffle</value>
   </property>
   <property>
      <name>yarn.nodemanager.env-whitelist</name>
      <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
   </property>
   <property>
      <name>yarn.nodemanager.resource.memory-mb</name>
      <value>4096</value>
   </property>
   <property>
      <name>yarn.scheduler.minimum-allocation-mb</name>
      <value>2048</value>
   </property>
   <property>
      <name>yarn.nodemanager.vmem-pmem-ratio</name>
      <value>2.1</value>
   </property>
</configuration>


```

#### 5. hadoop-env.sh
Open it:
```bash
nano $HADOOP_HOME/etc/hadoop/hadoop-env.sh
```
Add the following line to define the directory where Hadoop logs will be written:
```bash
export HADOOP_LOG_DIR=${HADOOP_HOME}/logs
```

### Step 5: Set Up Passwordless SSH
1. **Install OpenSSH:**
   ```bash
   sudo apt-get install openssh-server
   
   sudo dnf install -y openssh-server

   ```

2. **Generate SSH keys:**
   ```bash
   ssh-keygen -t rsa -P ""
   ```

3. **Add SSH key to authorized keys:**
   ```bash
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   
   chmod 600 ~/.ssh/authorized_keys
   ```

4. **Verify the SSH setup:**
   ```bash
   ssh localhost
   ```

---![Logo](./images/14.png)

### Step 6: Understanding `PDSH_RCMD_TYPE=ssh`

When configuring Hadoop in a pseudo-distributed environment, Hadoop uses SSH for communication between its components. To avoid permission issues, add the following line to your `.bashrc` file:
```bash
export PDSH_RCMD_TYPE=ssh
```

---

### Step 7: Format the NameNode
```bash
hdfs namenode -format
```

### Step 8: Start Hadoop Services
1. **Start HDFS:**
   ```bash
   start-dfs.sh
   ```

2. **Start YARN:**
   ```bash
   start-yarn.sh
   ```
![Logo](./images/3.png)
---

### Step 9: Verify Installation
1. Access the Hadoop NameNode Web UI at [http://localhost:9870](http://localhost:9870).
![Logo](./images/1.png)
2. Check YARN's ResourceManager Web UI at [http://localhost:8088](http://localhost:8088).
![Logo](./images/2.png)

