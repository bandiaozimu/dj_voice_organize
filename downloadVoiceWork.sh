#! /bin/bash

# working_dir : 本程式所在的路徑
working_dir='/Users/hentai/git/dj_voice_organize'

cd ${working_dir}
mkdir -p copy
#rm -rf copy/*

# ================================================================================
# fetchVoiceWork：從DJVoiceConfig.pm 裡定義的$POP_STORAGE_PATH 路徑下載作品，參數說明如下：
#           fetchVoiceWork -[df] [RJ###### RJ###### ....]
#           -d : 啟動下載，沒有給這參數，腳本只會列出下載所需空間
#           -f : 強制執行，沒有給這參數，腳本將剃除過去曾經下載過的作品(在資料庫的read欄位被設為8)
#           RJ###### : 指定作品ID，沒有給，腳本會讀取 WunderList 中被勾選的作品
./fetchVoiceWork $@

if ls copy/*RJ* 1> /dev/null 2>&1; then

    # ================================================================================
    # extractVoiceWork：解壓縮，轉檔，嵌入封面，id3 TAG。
    #       解壓縮：本腳本會不斷調用OSX的open 指令，直到copy目錄下沒有zip，rar等壓縮檔為止。若解壓
    #           出現問題導至壓縮檔留在copy目錄中，可手動刪檔，或ctrl-C 讓腳本停止等待。
    #
    #       檢查重復作品：有的作品因過去重復下載，fetchVoiceWork 也會將多個版本的作品都載下來，
    #           遇到此情況，extractVoiceWork會終止所有腳本，待我們篩選出唯一的版本留在copy裡。
    #           篩選後，執行 downloadVoiceWork.sh，不加任何參數即可接續剩下的步驟。
    #       
    #       轉檔：若copy目錄裡有wav，flac檔，會調用ffmpeg 進行轉檔成m4a。
    #
    #       封面，id3 TAG：調用atomicparsley為m4a 嵌入封面和id3 TAG；調用eyeD3為mp3 嵌入封面和id3 TAG。
    ./extractVoiceWork || exit


    # ================================================================================
    # importVoiceWork：移動所有mp3，m4a 檔進iTunes/iTunes Media/自動加入iTunes資料夾，更新資料庫，
    #       把加入的作品的read 欄位設為8 (IMPORTED)，並建立done_id_and_read.list提供reflashRecommendList
    #       計算新的「オススメ作品」。done_id_and_read內容簡單：
    #          RJ123456|2
    #          RJ789012|4   <- 4 代表此作品為「オススメ作品」中的項目
    #          RJ345678|2           必需找出新的項目取代之

    ./importVoiceWork 

    # ================================================================================
    # reflashRecommendList：根據read_id_and_read.list 計算「オススメ作品」中的哪些待辦事項需要新增，
    #       再根據DJVoiceConfig.pm 中的@RECOMMEND_CRITERIA_ARRAY 從資料庫撈新的推薦作品加進 WunderList

    ./reflashRecommendList 
#    rm done_id_and_read.list
fi



