#/bin/bash
ORACLE_HOME=$1/oracle
ORACLE_BASE=$1
function CreateDbDir(){
        if [ -d $1 ];
        then
                if [ -d $1/oracle ];
                then
                        echo "目录已存在"
                else
                        mkdir -p $1/{oracle,oraInventory}
                        chown -R oracle:oinstall $1
        else
                mkdir -p $1/{oracle,oraInventory}
                chown -R oracle:oinstall $1

        fi
}
function MountIso(){
        mkdir -p /media/iso
        if [ -f /root/CentOS-7-x86_64-DVD-1908.iso ];
        then
                mount -t iso9660 ./CentOS-7-x86_64-DVD-1908.iso  /media/iso/
                yum clean all
                cp -rf /etc/yum.repos.d/* /tmp/yum.repos.d/
                rm -rf  /etc/yum.repos.d/*
                touch /etc/yum.repos.d/local-centos7-iso.repo
                echo
                "
                [Server]
                name=Server
                baseurl=file:///media/iso
                enabled=1
                gpgckeck=1
                " >>  /etc/yum.repos.d/local-centos7-iso.repo
                yum clean all
                yum install -y binutils-2.* compat-libstdc++-33* elfutils-libelf-0.* elfutils-libelf-devel- * gcc-4.* gcc-c++4.* glibc-2.* glibc-common-2.* glibc-devel-2.* glibc-headers-2.* ksh-2.* libaio-0.* libaio-devel-0.* libgcc-4.* libstdc++-4.* libstdc++-devel-4.* make-3.* sysstat-7.* unixODBC-2.* unixODBC-devel-2.* pdksh*  --nogpgcheck
                yum install gcc make binutils gcc-c++ compat-libstdc++-33elfutils-libelf-devel elfutils-libelf-devel-static ksh libaio libaio-develnumactl-devel sysstat unixODBC unixODBC-devel pcre-devel –y --nogpgcheck
        else
                echo "ISO文件不存在,请上传CentOS-7-x86_64-DVD-1908.iso到root目录"
        fi
}
function InstallDb(){
        su - oracle
        cd $1/database
        source ~/.bash_profile
    ./runInstaller -silent -responseFile /home/oracle/db_install.rsp -ignorePrereq
}
function SetEnv(){
        hostnamectl set-hostname oracledb
    echo "127.0.0.1     oracledb" >>/etc/hosts
        sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
        setenforce 0
        echo "
        fs.aio-max-nr = 1048576
        fs.file-max = 6815744
        kernel.shmall = 2097152
        kernel.shmmax = 536870912
        kernel.shmmni = 4096
        kernel.sem = 250 32000 100 128
        net.ipv4.ip_local_port_range = 9000 65500
        net.core.rmem_default = 262144
        net.core.rmem_max = 4194304
        net.core.wmem_default = 262144
        net.core.wmem_max = 1048576
        " >> /etc/sysctl.conf
        sysctl -p
        cat << aof >> /etc/security/limits.conf
                oracle              soft    nproc   2047
                oracle              hard    nproc   16384
                oracle              soft    nofile  1024
                oracle              hard    nofile  65536
                aof

        cat << aof >> /etc/profile
                if [ $USER = "oracle" ]; then
                        if [ $SHELL = "/bin/ksh" ]; then
                                ulimit -p 16384
                                ulimit -n 65536
                else
                        ulimit -u 16384 -n 65536
                        fi
                fi
                aof

        cat << aof >> /home/oracle/.bash_profile
                umask 022
                export ORACLE_HOSTNAME=oracledb
                export ORACLE_BASE=$1
                export ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/
                export ORACLE_SID=ORCL
                export PATH=.:$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$ORACLE_HOME/jdk/bin:$PATH
                export LC_ALL="en_US"
                export LANG="en_US"
                export NLS_LANG="AMERICAN_AMERICA.ZHS16GBK"
                export NLS_DATE_FORMAT="YYYY-MM-DD HH24:MI:SS"
                aof
        source /home/oracle/.bash_profile
}

function CreateOracleUser(){
        groupadd oinstall
        groupadd dba
        useradd -g oinstall -G dba oracle
        unzip -q linux.x64_11gR2_database_1of2.zip -d $1
        unzip -q linux.x64_11gR2_database_2of2.zip -d $1
        mkdir -p /data/etc
        cp /data/database/response/* /data/etc/
        cat << eor >/home/oracle/db_response.rsp
                oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
                oracle.install.option=INSTALL_DB_SWONLY
                ORACLE_HOSTNAME=oracledb
                UNIX_GROUP_NAME=oinstall
                INVENTORY_LOCATION=/oraInventory
                SELECTED_LANGUAGES=en,zh_CN
                ORACLE_HOME=/home/sdyd/oracle/app/oracle/product/11.2.0/dbhome_1
                ORACLE_BASE=/home/sdyd/oracle/app/
                oracle.install.db.InstallEdition=EE
                oracle.install.db.isCustomInstall=false
                oracle.install.db.customComponents=oracle.server:11.2.0.1.0,oracle.sysman.ccr:10.2.7.0.0,oracle.xdk:11.2.0.1.0,oracle.rdbms.oci:11.2.0.1.0,oracle.network:11.2.0.1.0,oracle.network.listener:11.2.0.1.0,oracle.rdbms:11.2.0.1.0,oracle.options:11.2.0.1.0,oracle.rdbms.partitioning:11.2.0.1.0,oracle.oraolap:11.2.0.1.0,oracle.rdbms.dm:11.2.0.1.0,oracle.rdbms.dv:11.2.0.1.0,orcle.rdbms.lbac:11.2.0.1.0,oracle.rdbms.rat:11.2.0.1.0
                oracle.install.db.DBA_GROUP=dba
                oracle.install.db.OPER_GROUP=dba
                oracle.install.db.CLUSTER_NODES=
                oracle.install.db.config.starterdb.type=
                oracle.install.db.config.starterdb.globalDBName=
                oracle.install.db.config.starterdb.SID=orcl
                oracle.install.db.config.starterdb.characterSet=AL32UTF8
                oracle.install.db.config.starterdb.memoryOption=true
                oracle.install.db.config.starterdb.memoryLimit=
                oracle.install.db.config.starterdb.installExampleSchemas=false
                oracle.install.db.config.starterdb.enableSecuritySettings=true
                oracle.install.db.config.starterdb.password.ALL=
                oracle.install.db.config.starterdb.password.SYS=
                oracle.install.db.config.starterdb.password.SYSTEM=
                oracle.install.db.config.starterdb.password.SYSMAN=
                oracle.install.db.config.starterdb.password.DBSNMP=
                oracle.install.db.config.starterdb.control=DB_CONTROL
                oracle.install.db.config.starterdb.gridcontrol.gridControlServiceURL=
                oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false
                oracle.install.db.config.starterdb.dbcontrol.emailAddress=
                oracle.install.db.config.starterdb.dbcontrol.SMTPServer=
                oracle.install.db.config.starterdb.automatedBackup.enable=false
                oracle.install.db.config.starterdb.automatedBackup.osuid=
                oracle.install.db.config.starterdb.automatedBackup.ospwd=
                oracle.install.db.config.starterdb.storageType=
                oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=
                oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
                oracle.install.db.config.asm.diskGroup=
                oracle.install.db.config.asm.ASMSNMPPassword=
                MYORACLESUPPORT_USERNAME=
                MYORACLESUPPORT_PASSWORD=
                SECURITY_UPDATES_VIA_MYORACLESUPPORT=
                DECLINE_SECURITY_UPDATES=true
                PROXY_HOST=
                PROXY_PORT=
                PROXY_USER=
                PROXY_PWD=
                eof
