#!/bin/bash
#--------------
# 共通シェルスクリプト
SHELL_NAME=aide-check
SHELL_DESCRIBE="AIDE(ファイル改竄検知）の日次スキャン実施用シェル"
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
SCANLOG=/var/log/aide/scanresult.txt
AIDE_RULE=/etc/aide/aide.conf
AIDE_COMMAND=aide
AIDE_OPTION=--update
CALL_SHELL=$MY_PATH/gig_sendmail_aide_checkresult.sh

#スキャン実施
$AIDE_COMMAND --config=$AIDE_RULE $AIDE_OPTION > $SCANLOG

#スキャン結果を確認するシェルへの引き継ぎ
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,call ($CALL_SHELL)" >> $LOG_PATH
$CALL_SHELL

#終了ログを出力
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,exit." >> $LOG_PATH