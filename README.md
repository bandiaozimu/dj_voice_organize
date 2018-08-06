
#同人音聲資料庫系統

功能
-----------------------

1. 整理作品統一檔名，目錄規則，重複的作品不刪檔並於檔名後加「-1」「-2」以此類推。
2. 建立資料庫，紀錄作品的發行社團，屬性標籤，聲優。各作品下載數，每新增200次更新一次屬性標籤。
3. 解壓縮，轉檔，封面，id3 tag，匯入iTunes，一鍵完成。
4. 配合Wunderlist建立推薦清單，可定製推薦機制。
5. 可與JDownloader，FlexGet 對接，爬蟲-下載-整理-篩選-匯入itunes全自動化。
6. 配合Wunderlist的推播功能，可在下載完成推送通知，還可篩選推送的作品。
7. 本程式支持主機／客戶端的配置方式，即主機運行 FlexGet，JDownloader，及保存作品資料；
   客戶端運行解壓縮，轉檔，封面，id3 tag，匯入iTunes。
8. 本程式會將屬性標籤(調教/中出し/ナース...等) 嵌入id3 tag的「註解」中，方便iTues建立智慧播放清單。

![Image of Yaktocat](https://i.imgur.com/K5dpv8L.jpg)
![Image of Yaktocat](https://i.imgur.com/NutkgUX.png)
![Image of Yaktocat](https://i.imgur.com/WP6r4n0.png)

環境
-----------------------
本程式目前只對OSX做過調適。

本程式需要以下perl 模組，都可在cpan上找到：

    - Web::Query;
    - JSON;
    - Encode;
    - DBI;
    - Data::Dumper;
    - File::Copy;
    - File::Basename;
    - File::Find ();
    - File::chdir;
    - Getopt::Std;
    - List::Util qw( min max );
    - DateTime;


本程式需要以下程式協同運行：

    - atomicparsley
    - eyeD3
    - ffmpeg + fdk-aac
    - sqlite
    - gnu-sed
    - realpath
    - perl
    - curl

安裝協作程式
-----------------------
`atomicparsley`，`fdk-aac`，`eyeD3`，`gnu-sed`和`realpath`在OSX下可用`brew`或`pip`安裝：

```
brew install atomicparsley

brew install ffmpeg --with-fdk-aac

sudo pip install eyeD3

brew install gnu-sed

brew install coreutils
```

安裝主機端程式
-----------------------
1. 將DLSiteDB.db.sample重新命名為DLSiteDB.db：

    ```
    cd dj_voice_organize
    mv DLSiteDB.db.sample DLSiteDB.db
    ```

2. 編輯`DJVoiceConfig.pm.sample` 根據你的環境修改以下參數，並重新命名為`DJVoiceConfig.pm`：

    ```
    $WORKING\_DIR
    $CATCHE\_DIR
    $JDOWNLOADER\_DOWNLOAD\_DIR  # Jdownloader 的下載路徑，最好是給音聲作品專用，喂的資料越亂，出錯的機率會升高。
    $PUSH\_DATABASE\_PATH
    $PUSH\_STORAGE\_PATH
    ```

3. 運行下列指令，會根據`DJVoiceConfig.pm` 定義的路徑修改各shell script。

    ```
    ./setup -p
    ```

4. 開始整理作品，將要建檔的作品檔案都放入目錄裡，假設在`/Users/hentai/myVoicePart1` 裡，然後運行下列指令，建議分
多次處理，每次100個左右，被DLSite拉黑就不用玩了：

    ```
    ./buildVoiceWork.sh -s /Users/hentai/myVoicePart1
    ./buildVoiceWork.sh -s /Users/hentai/myVoicePart2
    ./buildVoiceWork.sh -s /Users/hentai/myVoicePart3
    ...
    ```

- 注1：資料庫裡有我已經建檔3000+個作品的基本資料，所以不會全都從DLSite上撈，但封面每部作品都要撈，動作太密集有被
拉黑的可能。
- 注2： -s 是安靜模式，此模式下`buildVoiceWork.sh` 不會做與wunderlist推播通知相關的運算。
- 注3：若不指定路徑，`buildVoiceWork.sh` 預設會處理 `$JDOWNLOADER\_DOWNLOAD\_DIR`。


與 WunderList 協作
-----------------------

1. 本腳本利用wunderlist作為清單和推播介面，請註冊兩個帳號，一發一收。發送端要登入以下網址申請開發者帳號，並建立App：

   [https://developer.wunderlist.com/apps](https://developer.wunderlist.com/apps)

   建立App時會要求填入app url和callback url，隨便填即可。建好後可拿到client id，
   再點右下角的「CREATE ACCESS TOKEN」按鈕可再得到一組access token，記下這兩組號碼，於下個步驟填入`DJVoiceConfig.pm`。

   ![Image of Yaktocat](http://i.imgur.com/TW3IH8P.png)

2. 編輯`DJVoiceConfig.pm` 修改以下參數：

    ```
    $POP\_DATABASE\_PATH    # setup -w 會透過此參數找資料庫
    $WUNDERLIST\_TOKEN
    $WUNDERLIST\_CLIENT\_ID
    $WUNDERLIST_RECEIVER_EMAIL
    ```

3. 運行下列指令，完成後WunderList的接收端帳號會收到兩個清單分享，選同意。

    ```
    ./setup -w
    ```

4. 兩個清單分別為： ダウンロード(下載)，オススメ作品(推薦作品)，「ダウンロード」會在主機端處理新作品時用到；
「オススメ作品」 則會在客戶端的iTunes匯入作品時使用。

- 注1：往後如果想設計自己的推薦清單，可以先修改 `@RECOMMEND\_CRITERIA\_ARRAY`，再運行此指令，運行過程中`setup -w` 會
檢查 query 的語法，沒問題才新增待辦事項(task)。

- 注2：只要 `$POP\_DATABASE\_PATH` 正確， `setup -w` 不論在主機端還是客戶端都能運行。


安裝客戶端程式
-----------------------

1. 請確認客戶端的預設解壓縮程式，在完成解壓縮後會刪除壓縮檔，本程式依靠壓縮檔的消失來判斷解壓完成與否。

2. 將主機端的 `dj\_voice\_organize` 資料夾複製一份到客戶端上，如果沒有做主機／客戶端配置，則跳至步驟3。

3. 編輯客戶端的`DJVoiceConfig.pm` 根據你的環境修改以下參數：

    ```
    $WORKING\_DIR
    $POP\_STORAGE\_PATH      # 以客戶端為起點，指向與主機端$PUSH\_STORAGE\_PATH 所指的同一個資料夾 
    $POP\_DATABASE\_PATH     # 以客戶端為起點，指向與主機端$PUSH\_DATABASE\_PATH 所指的同一個資料庫 
    $ITUNES\_PATH
    ```

4. 運行下列指令，會根據`DJVoiceConfig.pm` 定義的路徑修改各shell script。

    ```
    ./setup -p
    ```

5. 運行下列指令，會在WunderList的推薦清單裡填入符合條件的作品，第一次運行會比較花時間：

    ```
    ./reflashRecommendList
    ```

- 注：可修改`DJVoiceConfig.pm` 的`$COLUMN\_OF\_RECOMMEND\_LIST` 參數，增加清單長度。


運行客戶端程式
-----------------------

至此，已完成初步配置了，本程式在客戶端提供下列指令：

  下載RJ123456，RJ789012到客戶端，並匯入到iTunes，-d 是下載的意思：

  ```
  ./downloadVoiceWork.sh -d RJ123456 RJ789012 ...
  ```

  沒有指定作品時，將下載WunderList裡被勾選的作品，並匯入到iTunes：

  ```
  ./downloadVoiceWork.sh -d
  ```

  沒有 `-d` 時，僅計算被勾選的作品需要的空間，不下載：

  ```
  ./downloadVoiceWork.sh
  ./downloadVoiceWork.sh RJ123456 RJ789012 ...
  ```

  曾經匯入iTunes的作品將會在資料庫裡作標記，將被略過，除非在指令裡加 `-f` ，可強制下載：

  ```
  ./downloadVoiceWork.sh -f -d RJ123456 RJ789012 ...
  ```

`downloadVoiceWork.sh`會在匯入iTunes後順帶執行`reflashRecommendList`更新推薦清單。


與JDownloader 2 協作
-----------------------

1. 本程式可以配合JDownloader 2 監控下載路徑，過濾所有檔名含有RJ######的壓縮檔，下載完成自動整理進資料庫，
並篩選出你有興趣的作品做手機的推播通知。


2. 編輯主機端的`DJVoiceConfig.pm` 根據你的喜好修改以下參數：

    ```
    $NOTIFY\_DEFAULT\_THRESHOLD
    %NOTIFY\_CRITERIA\_HASH\_VOCAL
    %NOTIFY\_CRITERIA\_HASH\_HOLD\_TAG
    %NOTIFY\_CRITERIA\_HASH\_PASS\_TAG
    %NOTIFY\_CRITERIA\_HASH\_CIRCLE
    ```

   新作品的推播篩選，是根據發行社團，屬性標籤，聲優決定的。三者決定一個閥值，當下載數大於閥值則發
   送推播通知。
   計算閥值規則如下：

       缺省值(DEFAULT) ------------\
       喜好的屬性標籤(PASS_TAG) ---取最小值----
       聲優(VOCAL) ----------------/           \
                                                \
       討厭的屬性標籤(HOLD_TAG) -------------取最大值------
                                                           \
       發行社團(CIRCLE) ---------------------------------取最小值

3. 開啟Jdownloader 2 的script 功能，加入下列代碼：

    ```
    //Add your script here. Feel free to use the available api properties and methods
    var script = '/你/的/路/徑/dj_voice_organize/jdFinishEventHandler.sh'

    //var path = archive.getFolder()
    //var name = archive.getName()
    //var label = archive.getDownloadLinks() && archive.getDownloadLinks()[0].getPackage().getComment() ? archive.getDownloadLinks()[0].getPackage().getComment() : 'N/A'

    //var command = [script, path, name, label, 'ARCHIVE\_EXTRACTED']
    var command = [script]

    log(command)
    log(callSync(command))
    ```

4. 代碼的觸發條件我是選Package Finished，如果你是因為壓縮檔有密碼想讓JDownloader2 做解壓縮，
可選Archive Extraction Finished。

與 FlexGet 協作
-----------------------
為避免過多的爬蟲程式對網站造成攻擊，我只列出使用爬蟲腳本的必要條件：

1. 修改`DJVoiceConfig.pm` ：

    ```
    $JDOWNLOADER\_WATCH\_DIR  # Jdownloader 2 監控的資料夾，放入.crawjob 就會新增下載任務
    $USING\_FLEXGET           # 設為1
    ```

2. FlexGet 的 exec 需完成以下幾項工作：

    - 在 Jdownloader 2 監控的資料夾，放入.crawjob 就會新增下載任務

    - 檢查資料庫裡是否已有重複的作品，欄位`read = 0`或沒有id相符合的作品才下載
    
    - 每當開始新的下載任務，請對資料庫下這條指令：

        ```
          UPDATE JDownLoadVar SET value = 1 WHERE name = 'voiceWorkTrigger';
        ```


給開發者：
-----------------------
1. 下列議題如果有開發者完成，我會用 1.77 TB 的資料回報：

    - 我的系統是OSX，本程式若要在其它作業系統上運行，必需做修改，完成者，重謝。

    - 我的環境是在寫這個腳本的過程裡逐漸完備的，寫這文件時對如何安裝atomicparsley，eyeD3，fdk-aac，gnu-sed，
    perl各模組等都只能憑記憶寫，如果有高手能寫一個安裝這些協作軟件的腳本，重謝。

    - Wunderlist被Mircrsoft買斷，可能在一到兩年內停止服務，所以我寫到相關的功能都是用簡單的curl呼叫，沒有包裝，
    如果有高手能用ticktick，Microsoft to-do或任何適合的app取代，重謝。

2. 任何有用的小修小改，我都會以我正在用的爬蟲腳本做回報，不是多難的腳本，但爬蟲腳本用的人多了，或太頻繁
的刷新，網站就會防，然後我就得改，所以只給懂程式的人。


