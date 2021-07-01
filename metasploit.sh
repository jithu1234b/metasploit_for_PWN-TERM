#!/data/data/hilled.pwnterm/files/usr/bin/bash

#<<<------Intro------>>>>
printf "\e[1;97m      __  __     _____     ____        _         ___ _   \e[0m\n"
printf "\e[1;96m     |  \/  | __|_   _|_ _/ ___| _ __ | |    ___|_ _| |_ \e[0m\n"
printf "\e[1;36m     | |\/| |/ _ \| |/ _\` \___ \| '_ \| |   / _ \| || __|\e[0m\n"
printf "\e[1;93m     | |  | |  __/| | (_| |___) | |_) | |__| (_) | || |_ \e[0m\n"
printf "\e[1;33m     |_|  |_|\___||_|\__,_|____/| .__/|_____\___/___|\__|\e[0m\n"
printf "\e[1;91m                                |_|\e[1;34m IN PWN-TERM \e[0m\n"
sleep 1
echo
pfetch
sleep 2
#<<<------INSTALLTION PROCESS------>>>

#<<<------Remove  Old Folder if exist------>>> 
find $HOME -name "metasploit-*" -type d -exec rm -rf {} \;


cwd=$(pwd)
msfvar=6.0.33
msfpath='/data/data/hilled.pwnterm/files/usr/home'

apt update && apt upgrade
#<<<------Temporary------>>> 
apt remove ruby -y
apt install -y libiconv zlib autoconf bison clang coreutils curl findutils git apr apr-util libffi libgmp libpcap postgresql readline libsqlite openssl libtool libxml2 libxslt ncurses pkg-config wget make ruby2 libgrpc termux-tools ncurses-utils ncurses unzip zip tar termux-elf-cleaner
#<<<------Many phones are claiming (libxml2 not found) error------>>>
ln -sf /data/data/hilled.pwnterm/files/usr/include/libxml2/libxml /data/data/hilled.pwnterm/files/usr/include/

cd $msfpath
curl -LO https://github.com/rapid7/metasploit-framework/archive/$msfvar.tar.gz

tar -xf $msfpath/$msfvar.tar.gz
mv $msfpath/metasploit-framework-$msfvar $msfpath/metasploit-framework
cd $msfpath/metasploit-framework

#<<<------Update rubygems-update------>>>
if [ "$(gem list -i rubygems-update 2>/dev/null)" = "false" ]; then
	gem install --no-document --verbose rubygems-update
fi

#<<<------Update rubygems------>>>
update_rubygems

#<<<------Install bundler------>>>
gem install --no-document --verbose bundler:1.17.3

#<<<------Installing all gems------>>> 
bundle config build.nokogiri --use-system-libraries
bundle install -j3
echo "Gems installed"

#<<<------Some fixes------>>>
sed -i "s@/etc/resolv.conf@$PREFIX/etc/resolv.conf@g" $msfpath/metasploit-framework/lib/net/dns/resolver.rb
find "$msfpath"/metasploit-framework -type f -executable -print0 | xargs -0 -r termux-fix-shebang
find "/data/data/hilled.pwnterm/files/usr"/lib/ruby/gems -type f -iname \*.so -print0 | xargs -0 -r termux-elf-cleaner

echo "Creating database"

mkdir -p $msfpath/metasploit-framework/config && cd $msfpath/metasploit-framework/config
curl -LO https://raw.githubusercontent.com/jithu1234b/metasploit_for_PWN-TERM/main/database.yml

mkdir -p /data/data/hilled.pwnterm/files/usr/var/lib/postgresql
pg_ctl -D "$PREFIX"/var/lib/postgresql stop > /dev/null 2>&1 || true

if ! pg_ctl -D "/data/data/hilled.pwnterm/files/usr"/var/lib/postgresql start --silent; then
    initdb "/data/data/hilled.pwnterm/files/usr"/var/lib/postgresql
    pg_ctl -D "/data/data/hilled.pwnterm/files/usr"/var/lib/postgresql start --silent
fi
if [ -z "$(psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='msf'")" ]; then
    createuser msf
fi
if [ -z "$(psql -l | grep msf_database)" ]; then
    createdb msf_database
fi

rm $msfpath/$msfvar.tar.gz

cd ${PREFIX}/bin && curl -LO  https://raw.githubusercontent.com/jithu1234b/metasploit_for_PWN-TERM/main/msfconsole && chmod +x msfconsole

ln -sf $(which msfconsole) /data/data/hilled.pwnterm/files/usr/bin/msfvenom

echo "you can directly use msfvenom or msfconsole rather than ./msfvenom or ./msfconsole."

