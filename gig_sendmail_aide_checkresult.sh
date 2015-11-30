#!/bin/sh
#--------------
# 共通シェルスクリプト
SHELL_NAME=gig_sendmail_aide_checkresult
SHELL_DESCRIBE="aideの日次スキャン結果をメール送信するためのシェル"
#--------------
#自身のパス取得
MY_PATH=$(dirname $0)

#シェルの設定
PARAM_NUM=0
PARAM_DESCRIBE=""

#シェルの共通設定
COMMON_LOG_DIR=/var/log/common
COMMON_LOG_FILE=gigjob
LOG_PATH=$COMMON_LOG_DIR/$COMMON_LOG_FILE.log
SENDMAIL_SHELL=$MY_PATH/gig_sendmail.sh
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

#起動ログを出力
echo "$WAKEUP_DATESTR ,[INFO],$SHELL_NAME,wakeup on $MY_PATH" >> $LOG_PATH

#このシェル固有の設定
#clamavのスキャン結果のパス
CHKLOG=/var/log/aide/scanresult.txt
SBJFILE=/tmp/msbj_$SHELL_NAME
BODYFILE=/tmp/mbody_$SHELL_NAME
ERRLVL=INFO

#変更検出の有無を判定するためのチェック
#cat $CHKLOG | grep "Infected files: 0"の結果が0なら、感染したファイル1つ以上
if [ -z "$(cat $CHKLOG | grep "Looks okay")" ]; then
      TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
      echo "$TMPDATESTR ,[WARN],$SHELL_NAME, Find change !" >> $LOG_PATH
      ERRLVL=WARN
fi

#メールのタイトルに設定する文面
MAIL_SBJ="($ERRLVL) AIDE change tracer Scan Result from $SHELL_NAME.sh"
echo $MAIL_SBJ > $SBJFILE

#メール通知対象は以下で出てきた内容
echo "[mail body]" > $BODYFILE
cat $CHKLOG | grep "Number of entries" >> $BODYFILE
cat $CHKLOG | grep "Start timestamp" >> $BODYFILE
cat $CHKLOG | grep "End timestamp" >> $BODYFILE
echo "================= Change Logs ========================" >> $BODYFILE
cat $CHKLOG | grep added >> $BODYFILE
cat $CHKLOG | grep changed >> $BODYFILE

#メール送信シェル起動
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,call ($SENDMAIL_SHELL $SBJFILE $BODYFILE)" >> $LOG_PATH
$SENDMAIL_SHELL $SBJFILE $BODYFILE

#終了ログを出力
TMPDATESTR=`date +"%Y/%m/%d,%H:%M:%S"`
echo "$TMPDATESTR ,[INFO],$SHELL_NAME,exit." >> $LOG_PATH