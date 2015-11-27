#!/bin/bash
#--------------
# 共通シェルスクリプト
SHELL_NAME=clamav-check
SHELL_DESCRIBE="clamavの日次スキャン実施用シェル"
#--------------
PATH=/usr/bin:/bin

#自身のパス取得
MY_PATH=$(dirname $0)

#シェルの共通設定
COMMON_LOG_DIR=/var/log/common
COMMON_LOG_FILE=gigjob
LOG_PATH=$COMMON_LOG_DIR/$COMMON_LOG_FILE.log
WAKEUP_DATESTR=`date +"%Y/%m/%d,%H:%M:%S"`

#起動ログを出力
echo "$WAKEUP_DATESTR ,[INFO],$SHELL_NAME,wakeup on $MY_PATH" >> $LOG_PATH

#このシェル固有の設定
UPGLOG=/var/log/clamav/upgraderesult.txt
CHKLOG=/var/log/clamav/scanresult.txt
CALL_SHELL=/etc/gigcommon/gig_sendmail_clamav_checkresult.sh
excludelist=/etc/clamav/clamscan.exclude

# clamd本体のアップグレード
apt-get upgrade -y clamav-daemon > $UPGLOG 2>&1
apt-get upgrade -y clamav-freshclam >> $UPGLOG 2>&1

# 検索対象から除外するパスの設定
if [ -s $excludelist ]; then
    for i in `cat $excludelist`
    do
        if [ $(echo "$i"|grep \/$) ]; then
            i=`echo $i|sed -e 's/^\([^ ]*\)\/$/\1/p' -e d`
            excludeopt="${excludeopt} --exclude-dir=^$i"
        else
            excludeopt="${excludeopt} --exclude=^$i"
        fi
    done
fi

#スキャン実施
clamscan --recursive --remove ${excludeopt} / > $CHKLOG 2>&1

#スキャン結果を確認するシェルへの引き継ぎ
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,call ($CALL_SHELL)" >> $LOG_PATH
$CALL_SHELL

#終了ログを出力
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,exit." >> $LOG_PATH