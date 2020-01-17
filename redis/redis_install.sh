read -p "Enter redisdir > " redisdir
echo "redis安装根目录:$redisdir"

unzip redis-5.0.5.zip -d $redisdir/redis/
cd $redisdir/redis/redis-5.0.5
mkdir -p $redisdir/638{0,1,2,3,4,5}
cp $redisdir/redis/redis-5.0.5/redis.conf $redisdir/6380/redis-6380.conf
cp $redisdir/redis/redis-5.0.5/redis.conf $redisdir/6380/redis-6381.conf
cp $redisdir/redis/redis-5.0.5/redis.conf $redisdir/6380/redis-6382.conf
cp $redisdir/redis/redis-5.0.5/redis.conf $redisdir/6380/redis-6383.conf
cp $redisdir/redis/redis-5.0.5/redis.conf $redisdir/6380/redis-6384.conf
cp $redisdir/redis/redis-5.0.5/redis.conf $redisdir/6380/redis-6385.conf

function start(){
.$redisdir/redis/redis-5.0.5/src/redis-server  $redisdir/6380/redis-6380.conf
.$redisdir/redis/redis-5.0.5/src/redis-server  $redisdir/6381/redis-6381.conf
.$redisdir/redis/redis-5.0.5/src/redis-server  $redisdir/6382/redis-6382.conf
.$redisdir/redis/redis-5.0.5/src/redis-server  $redisdir/6383/redis-6383.conf
.$redisdir/redis/redis-5.0.5/src/redis-server  $redisdir/6384/redis-6384.conf
.$redisdir/redis/redis-5.0.5/src/redis-server  $redisdir/6385/redis-6385.conf
echo "#############集群启动#################"
.$redisdir/redis/redis-5.0.5/src/redis-cli --cluster create 127.0.0.1:6380 127.0.0.1:6381 127.0.0.1:6382 127.0.0.1:6383 127.0.0.1:6384 127.0.0.1:6385 --cluster-replicas 1
}
