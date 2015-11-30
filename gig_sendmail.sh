#!/bin/sh
#--------------
# 共通シェルスクリプト
SHELL_NAME=gig_sendmail
SHELL_DESCRIBE="Sendmailによりメール送信するためのシェル"
# param $1 : テキストファイルへのパス、内容がメールのタイトルになる
# param $2 : テキストファイルへのパス、内容がメールの本文になる
#--------------
#自身のパス取得
MY_PATH=$(dirname $0)

#シェルの設定
PARAM_NUM=2
PARAM_DESCRIBE="FILE(MAILTITLE) FILE(MAILBODY)"

#シェルの共通設定
COMMON_LOG_DIR=/var/log/common
COMMON_LOG_FILE=gigjob
LOG_PATH=$COMMON_LOG_DIR/$COMMON_LOG_FILE.log
WAKEUP_DATESTR=`date +"%Y/%m/%d,%H:%M:%S"`

#引数チェック
if [ $# -ne $PARAM_NUM ]; then
        echo "[ERROR] invalid argument."
        echo "[ $SHELL_NAME.sh ]"
        echo "($SHELL_DESCRIBE)"
        echo "Usage : $SHELL_NAME.sh $PARAM_DESCRIBE"
        #起動ログを出力
        echo "$WAKEUP_DATESTR ,[ERROR],$SHELL_NAME,invalid argument." >> $LOG_PATH
        exit
fi

#このシェル固有の設定
#起動ログを出力
echo "$WAKEUP_DATESTR ,[INFO],$SHELL_NAME,wakeup on $MY_PATH, param: $1 ,$2 " >> $LOG_PATH
#メールの共通設定
MAIL_FROM=`cat /etc/mail/mail_address_from.txt`
MAIL_TO=`cat /etc/mail/mail_address_to.txt`

#メール文面の一時保存領域
PD_FILE=/tmp/mailfile

echo "From: $MAIL_FROM" > $PD_FILE
echo "To: $MAIL_TO" >> $PD_FILE
echo "Subject: [`(hostname)`] `(cat $1)`" >> $PD_FILE
echo "" >> $PD_FILE
cat $2 >> $PD_FILE

/usr/sbin/sendmail $MAIL_TO < $PD_FILE

#終了ログを出力
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,exit." >> $LOG_PATH