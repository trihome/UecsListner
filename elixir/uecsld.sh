#!/bin/bash
#--------------------------------------------------------------------
#バックグラウンドで実行するBashスクリプト
#--------------------------------------------------------------------

#変数の設定
SCRIPTDIR=/home/kenkyu/gitwork/elixir/uecslistner
LOGDIR=$SCRIPTDIR/log

#実行
cd $SCRIPTDIR
if [ -d $LOGDIR ]; then
    exec /usr/bin/elixir --no-halt --sname uecsld -S mix >> $LOGDIR/run.log 2>&1
    #返り値：正常終了
    exit 0
else
    echo " ! Not Found log directory: ${SCRIPTDIR}."
    #返り値：異常終了
    exit 1
 fi


