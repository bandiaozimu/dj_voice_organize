#! /bin/bash

# ***** 運行前請先修改以下三個參數：

# working_dir : 本程式所在的路徑
working_dir='/Users/hentai/git/dj_voice_organize'

# target：目標檔案所在的路徑，通常是指JDownloader的下載目錄
jdownload_dir='/Users/hentai/git/dj_voice_organize/test/dummy'
# ================================================================================
# catche_dir：暫存目錄，我把保存的作品資料放在外接硬碟，而下載目錄則在本機硬碟
# 這讓我在buildDLSite腳本搬移檔案時遇到麻煩，所以我在外接硬碟裡建一個暫存目錄，
# 在運行buildDLSite前先將新作品移至此目錄，以保證buildDLSite處理的檔都在同個硬碟裡
# 此目錄在程式運行完後也用來存放過程中產生的紀錄檔*.log，或出錯時的暫存檔*.json。
catche_dir='/Users/hentai/git/dj_voice_organize/test/log'


old_work_json_file='old_works.json'
select_json_file='select.json'
while getopts ":s" opt
do
    case $opt in
        s)
            opt_s='ture'
            old_work_json_file=''
            select_json_file=''
            shift
            ;;
        ?)
            echo "error"
            exit 1
    esac
done


# ================================================================================

target=${1:-$jdownload_dir}
target=$(realpath ${target})

date1=$(date +%y%m%d%H%M)
path2=${catche_dir}/voice${date1}

if ls ${target}/*RJ* 1> /dev/null 2>&1; then
    mkdir "${path2}"
    cd ${working_dir}
    # ============================================================================
    # reflashDLSiteDB ：刷新資料庫的下載數，屬性標籤。為避免過量讀取DLSite的資料被封鎖，
    #     我依照下面的機制挑選更新的作品：
    #
    #        1 個月內的新作依序挑 50 個更新下載數
    #        2 到  4 個月內的作品挑 25 個更新下載數
    #        5 到 16 個月內的作品挑 15 個更新下載數
    #       17 個月以上的作品挑 10 個更新下載數
    #       當作品下載數增加 200 次，更新該作的屬性標籤
    #
    #     被選中的作品會以 JSON 格式喂給標準輸出，此處被重導至old_works.json

    if [ -z "${opt_s}" ]; then 
        echo "----- reflashDLSiteDB"
        ./reflashDLSiteDB ${old_work_json_file} >${date1}.reflashDB.log
    fi

    echo "----- move to ${path2}"
    find "${target}" -maxdepth 1 -mindepth 1 -name '*RJ*' '!' -exec sh -c 'ls -1 "{}"|egrep -q ".*\.part$"' ';' -print | xargs -I {} mv {} "${path2}"

    # ============================================================================
    # unfoldDLSiteFile：將下載的檔案重新整理，壓縮分割檔會以作品為單位打包成目錄，目錄名以
    #     原檔名為依據，以統一的規則命名，所以不會被舊目錄名影響。
    #         (同人音声) [yyyymmdd] [發行社團] 作品名 RJ######

    echo "----- unfoldDLSiteFile"
    ./unfoldDLSiteFile "${path2}" >${date1}.unfold.log


    # ============================================================================
    # grapDLCount：從DLSite 擷取作品的下載數，reflashDLSiteDB 裡也有調用此腳本，在這是擷取新作的資料
    #     和reflashDLSiteDB 一樣，擷取的資料以 JSON 格式重導至new_works.json
    #     old_work.json 和 new_work.json 是推播通知的備選作品。

    echo "----- grapDLCount"
    find "${path2}" -maxdepth 1 -name '*RJ*' | ./grapDLCount >new_works.json

    # ============================================================================
    # buildDLSite：將新作品資料寫入資料庫，並將檔案按照發行社團移至保存的路徑
    #     保存作品的路徑使用在DJVoiceConfig.pm 裡定義的 $PUSU_STORAGE_PATH
    echo "----- buildDLSite"
    ./buildDLSite new_works.json "${path2}" >${date1}.build.log 2>>${date1}.err.log
    if [ -s ${date1}.err.log ] ; then
        mv new_works.json "${path2}"
        find ${date1}.*.log -exec mv {} "${path2}" \;
        exit 1
    fi


    if [ -z "${opt_s}" ]; then 
        # ============================================================================
        # tagFilter：新作品的推播篩選，是根據發行社團，屬性標籤，聲優決定的。三者決定一個閥值，
        #     當下載數大於閥值則通過篩選，通過篩選的作品以 JSON 格式寫入select.json，交由腳本
        #     notifyDLComplishment 發送推播通知。計算閥值規則如下：
        #
        #        缺省值(DEFAULT) ------------\
        #        喜好的屬性標籤(PASS_TAG) ---取最小值----
        #        聲優(VOCAL) ----------------/           \
        #                                                 \
        #        討厭的屬性標籤(HOLD_TAG) -------------取最大值------
        #                                                            \
        #        發行社團(CIRCLE) ---------------------------------取最小值
        # 
        #     必需說明的是，tagFilter對更新下載數前就已經達標的作品視為舊作品，不會放行。舊作的
        #     篩選我利用 reflashRecommandList 和 voiceWorkSelection 管理下的「オススメ作品」來進行。
        #
        #     tagFilter 的標準輸出詳細表列了各作品的篩選過程，值得一看。
        echo "----- tagfilter"
        ./tagFilter ${select_json_file} ${old_work_json_file} new_works.json >${date1}.filter.log

        # ============================================================================
        # reflashWunderList：更新清單「ダウンロード」中的下載數，方便我判斷哪個作品是目前較受追棒的。
        #
        # notifyDLComplishment：將通過篩選的新作整理後加入清單「ダウンロード」並發一則推播通知。
        #
        echo "----- reflashWunderList"
        ./reflashWunderList ${old_work_json_file}
        echo "----- notifyDLComplishment"
        ./notifyDLComplishment ${select_json_file} 2>>${date1}.err.log
    fi
    if [ ! -s ${date1}.err.log ] ; then
        rm ${date1}.err.log
        rm new_works.json ${old_work_json_file} ${select_json_file}
        find RJ*.html -exec rm {} \;
    else
        mv new_works.json ${old_work_json_file} ${select_json_file} "${path2}"
    fi
    find ${date1}.*.log -exec mv {} "${path2}" \;
else
    echo "files RJ###### do not exist"
fi

