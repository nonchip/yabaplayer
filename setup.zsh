#!/bin/zsh

export YP_PATH="$(dirname $(readlink -f $0))"
export YP_REAL_ROOT="$YP_PATH/.root"
export YP_SRC="$YP_PATH/.src"
export YP_ROOT="/tmp/.yabaplayer.$(uuidgen -t)-$(uuidgen -r)"

continue_stage=n
if [ -f "$YP_PATH/.continue_stage" ]
  then continue_stage=$(cat "$YP_PATH/.continue_stage")
fi

if [ -f "$YP_PATH/.continue_root" ]
  then YP_ROOT=$(cat "$YP_PATH/.continue_root")
fi

case $continue_stage in
  n)
    rm -f "$YP_PATH/.continue_stage"
    rm -rf "$YP_ROOT" "$YP_SRC" "$YP_REAL_ROOT"
    mkdir -p "$YP_REAL_ROOT" "$YP_SRC"
    ln -s "$YP_REAL_ROOT" "$YP_ROOT"
    echo "$YP_ROOT" > "$YP_PATH/.continue_root"
    ;&
  luajit) v=126e55d416ad10dc9265593b73b9f322dbf9d658
    echo "luajit" > "$YP_PATH/.continue_stage"
    cd $YP_SRC
    git clone http://luajit.org/git/luajit-2.0.git luajit || exit
    cd luajit
    git checkout ${v}
    git pull
    make amalg PREFIX=$YP_ROOT CPATH=$YP_ROOT/include LIBRARY_PATH=$YP_ROOT/lib && \
    make install PREFIX=$YP_ROOT || exit
    ln -sf $(find $YP_ROOT/bin/ -name "luajit-2.1*" | head -n 1) $YP_ROOT/bin/luajit
    ;&
  luarocks) v=e3203adbc3f5daa5f46097d3439edbada01807f3
    echo "luarocks" > "$YP_PATH/.continue_stage"
    cd $YP_SRC
    git clone git://github.com/keplerproject/luarocks.git || exit
    cd luarocks
    git checkout ${v}
    git pull
    ./configure --prefix=$YP_ROOT \
                --lua-version=5.1 \
                --lua-suffix=jit \
                --with-lua=$YP_ROOT \
                --with-lua-include=$YP_ROOT/include/luajit-2.1 \
                --with-lua-lib=$YP_ROOT/lib/lua/5.1 \
                --force-config && \
    make build && make install || exit
    ;&
  moonscript)
    echo "moonscript" > "$YP_PATH/.continue_stage"
    $YP_ROOT/bin/luarocks install moonscript
    ;&
  lanes)
    echo "lanes" > "$YP_PATH/.continue_stage"
    $YP_ROOT/bin/luarocks install lanes
    ;&
  JACKlib)
    echo "JACKlib" > "$YP_PATH/.continue_stage"
    $YP_PATH/lib/JACK/build.sh
    ;&
  wrappers)
    echo "wrappers" > "$YP_PATH/.continue_stage"
    # wrappers
    cat > $YP_PATH/.run <<END
#!/bin/zsh
export YP_PATH="\$(dirname "\$(readlink -f "\$0")")"
export YP_REAL_ROOT="\$YP_PATH/.root"
export YP_ROOT="$YP_ROOT"

[ -e "\$YP_ROOT" ] || ln -s "\$YP_PATH/.root" \$YP_ROOT

export PATH="\$YP_ROOT/bin:\$YP_ROOT/nginx/sbin:\$PATH"
export LUA_PATH="./custom_?.lua;\$YP_PATH/custom_?.lua;./?.lua;./?/init.lua;\$YP_PATH/src/?/init.lua;\$YP_PATH/src/?.lua;\$YP_PATH/?.lua;\$LUA_PATH;\$YP_ROOT/lualib/?.lua;\$YP_ROOT/share/luajit-2.1.0-alpha/?.lua;\$YP_ROOT/share/lua/5.1/?.lua;\$YP_ROOT/share/lua/5.1/?/init.lua"
export LUA_CPATH="./custom_?.so;\$YP_PATH/custom_?.so;./?.so;\$YP_PATH/lib/?/?.so;./?/init.so;\$YP_PATH/src/?/init.so;\$YP_PATH/src/?.so;\$YP_PATH/?.so;\$LUA_CPATH;\$YP_ROOT/lualib/?.so;\$YP_ROOT/share/luajit-2.1.0-alpha/?.so;\$YP_ROOT/share/lua/5.1/?.so;\$YP_ROOT/share/lua/5.1/?/init.so"
export MOON_PATH="./custom_?.moon;\$YP_PATH/custom_?.moon;./?.moon;./?/init.moon;\$YP_PATH/src/?/init.moon;\$YP_PATH/src/?.moon;\$YP_PATH/?.moon;\$MOON_PATH;\$YP_ROOT/lualib/?.moon;\$YP_ROOT/share/luajit-2.1.0-alpha/?.moon;\$YP_ROOT/share/lua/5.1/?.moon;\$YP_ROOT/share/lua/5.1/?/init.moon"
export LD_LIBRARY_PATH="\$YP_ROOT/lib:\$LD_LIBRARY_PATH"

fn=\$(basename \$0)
if [ "\$fn" = ".run" ]
  then exec "\$@"
else
  exec \$fn "\$@"
fi
END
    chmod a+rx $YP_PATH/.run
    ln -sf .run $YP_PATH/moon
    ;&
esac

# cleanup
rm -rf "$YP_SRC"
rm -f "$YP_ROOT" "$YP_PATH/.continue_stage" "$YP_PATH/.continue_root"
