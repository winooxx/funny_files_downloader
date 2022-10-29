#!/bin/bash

funnyUsername='censored'
funnyPassword='censored'
funnyServer='http://some-random-funny-url.com'
funnyDirectory='/some_random_path'
currentDate=$(date +%Y-%m-%d)

# IFTTT Notification Settings
iftttWebHookTrigger='some_random_funny_files_updated'
iftttWebHookKey='censored'

# Telegram Settings
telegramBotToken='censored'
telegramChannelId='censored'
telegramDevChannelId='censored'
telegramRandomChannelId='censored'
telegramPostUrl="https://api.telegram.org/bot${telegramBotToken}/sendMessage"

function main()
{
  # A ugly workaround, should be replaced with absolute path.
  cd ${funnyDirectory}
  download_funny_list
  convert_funny_list
  download_file
}

function download_funny_list()
{
  echo '==================================='
  echo 'Now downloading some_random_funny_files.list'
  echo '==================================='

  # Stimulate how funny software send the request to get some_random_funny_files
  funnyAuth=$(echo -n ${funnyUsername}:${funnyPassword} | base64)
  curl -o some_random_funny_files.list "${funnyServer}/some_random_funny_files.list" -H "Authorization: Basic ${funnyAuth}" -H 'User-Agent: ' -H 'Accept-Encoding: gzip, deflate'
}

function convert_funny_list()
{
  echo '============================================='
  echo 'Now converting some_random_funny_files.list into batch'
  echo '============================================='

  # Spilt file path from column 3 and output to a specific file
  awk 'NR>3{print $3}' some_random_funny_files.list > funny_download_list.txt
  rm -f some_random_funny_files.list
}

function compare()
{
  file1='./funny_download_list.txt'
  file2='./funny_download_list_old.txt'

  if [ ! -f $file2 ]
  then
    return 1
  fi

  diff $file1 $file2 > /dev/null
  if [ $? != 0 ]
  then
    return 1
  else
    return 0
  fi
}

function download_file()
{
  compare
  needUpdate=$?

  # Detect whether the funny_list is updated or not
  if [ ${needUpdate} -eq 1 ]
  then
    # By default, IFTTT notification is disabled before it is configured.
    # You can uncomment the send_ifttt_notification function below to enable it once you've configured your IFTTT Recipe.

    send_ifttt_notification
    send_telegram_notification
    echo '================================='
    echo 'Now downloading the some_random_funny_files'
    echo '================================='
    mkdir funny_${currentDate}
    cd funny_${currentDate}
      wget -U -x -r -L -nH --cut-dirs=4 -B "${funnyServer}/some_random_funny_files/" -i ../funny_download_list.txt --user=${funnyUsername} --password=${funnyPassword}
    cd ..
  else
    echo '=================================================='
    echo 'No update for some_random_funny_files, download terminated.'
    echo '=================================================='
  fi
  mv -f funny_download_list.txt funny_download_list_old.txt
}

function send_ifttt_notification()
{
  curl -X POST https://maker.ifttt.com/trigger/${iftttWebHookTrigger}/with/key/${iftttWebHookKey}
  echo ''
}

function send_telegram_notification()
{
  title=$(printf "$(date +%Y-%m-%d)\nsome_random_funny_files更新\n推送/更新了以下文件:\n")
  content=$(diff $file1 $file2 | awk '{print $2}')
  curl --data-urlencode "chat_id=${telegramChannelId}" --data-urlencode "text=$title $content" -X POST ${telegramPostUrl}
  curl --data-urlencode "chat_id=${telegramRandomChannelId}" --data-urlencode "text=$title $content" -X POST ${telegramPostUrl}
  echo ''
}

main

