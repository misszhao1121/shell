#关闭selinux
setenforce 0
#关闭防火墙
systemctrl stop firewalld
#安装依赖包
yum -y install wget sqlite-devel xz gcc automake zlib-devel openssl-devel epel-release

#编译安装
wget https://www.python.org/ftp/python/3.6.1/Python-3.6.1.tar.xz
tar xvf Python-3.6.1.tar.xz && cd  Python-3.6.1
./configure && make
make install

cd /opt
python3 -m venv py3
source /opt/py3/bin/activate
#安装git并下载clone项目
cd /opt/
yum -y install git 
git clone --depth=1 https://github.com/jumpserver/jumpserver.git && cd jumpserver && git checkout dev
#安装依赖rpm包
cd /opt/jumpserver/requirements
yum -y install $(cat rpm_requirements.txt)
#安装python库依赖
pip install -r requirements.txt
#安装redis,jumpserver用redis做缓存
yum -y install redis
systemctrl start redis
#安装mysql
yum -y install mariadb mariadb-devel mariadb-server
systemctrl start mariadb

HOSTNAME="127.0.0.1"                                          
 #数据库信息
PORT="3306"
USERNAME="jumpserver"
PASSWORD="somepassword"
DBNAME="jumpserver"                                                      
 #数据库名称
#TABLENAME="test_table_test"                                           数据库中表的名称
create_db_sql="create database IF NOT EXISTS ${DBNAME}"
mysql -h${HOSTNAME}  -P${PORT}  -u${USERNAME} -p${PASSWORD} -e "${create_db_sql}"
if [ $? = 0 ]; then
    echo "mysql success!!!!!!!!!!!"
fi

cd /opt/jumpserver
cp config_example.py config.py

cd /opt/jumpserver/utils
bash make_migrations.sh
if [ $? = 0 ]; then
    echo "生成数据成功"
fi

cd /opt/jumpserver
python run_server.py all

if [ $? = 0 ]; then
   echo "请带浏览器访问"
fi



