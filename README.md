# CerNerOld
Old TG

[mr.amirbagheri](https://telegram.me/mrcliapi)

[channel](https://telegram.me/CerNerCH)

[install](#install)

[installapi](#apiRun)
#install 

```sh
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev
```

```sh
git clone https://github.com/amir-cli/CerNerOld
cd CerNerOld 
chmod +x cernercli.sh
./cernercli.sh install
./cernercli.sh # add phone
```

#Run Api Telegram bot
#apiRun
```sh
cd $Ho
rm -rf .telegram-cli
cd CerNerOld
chmod +x cernerapi.sh
./cernerapi.sh # add token hash
```
