
#同人音声资料库系统

功能
-----------------------

1. 整理作品统一档名，目录规则，重复的作品不删档并于档名后加“-1”“-2”以此类推。
2. 建立资料库，纪录作品的发行社团，属性标签，声优。各作品下载数，每新增200次更新一次属性标签。
3. 解压缩，转档，封面，id3 tag，汇入iTunes，一键完成。
4. 配合Wunderlist建立推荐清单，可定制推荐机制。
5. 可与JDownloader，FlexGet 对接，爬虫-下载-整理-筛选-汇入itunes全自动化。
6. 配合Wunderlist的推播功能，可在下载完成推送通知，还可筛选推送的作品。
7. 本程式支持主机／客户端的配置方式，即主机运行 FlexGet，JDownloader，及保存作品资料；
   客户端运行解压缩，转档，封面，id3 tag，汇入iTunes。
8. 本程式会将属性标签(调教/中出し/ナース...等) 嵌入id3 tag的“注解”中，方便iTues建立智慧播放清单。

![Image of Yaktocat](https://i.imgur.com/K5dpv8L.jpg)
![Image of Yaktocat](https://i.imgur.com/NutkgUX.png)
![Image of Yaktocat](https://i.imgur.com/WP6r4n0.png)

环境
-----------------------
本程式目前只对OSX做过调适。

本程式需要以下perl 模组，都可在cpan上找到：

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


本程式需要以下程式协同运行：

    - atomicparsley
    - eyeD3
    - ffmpeg + fdk-aac
    - sqlite
    - gnu-sed
    - realpath
    - perl
    - curl

安装协作程式
-----------------------
`atomicparsley`，`fdk-aac`，`eyeD3`，`gnu-sed`和`realpath`在OSX下可用`brew`或`pip`安装：

```
brew install atomicparsley

brew install ffmpeg --with-fdk-aac

sudo pip install eyeD3

brew install gnu-sed

brew install coreutils
```

安装主机端程式
-----------------------
1. 将DLSiteDB.db.sample重新命名为DLSiteDB.db：

    ```
    cd dj_voice_organize
    mv DLSiteDB.db.sample DLSiteDB.db
    ```

2. 编辑`DJVoiceConfig.pm.sample` 根据你的环境修改以下参数，并重新命名为`DJVoiceConfig.pm`：

    ```
    $WORKING_DIR
    $CATCHE_DIR
    $JDOWNLOADER_DOWNLOAD_DIR  # Jdownloader 的下载路径，最好是给音声作品专用，喂的资料越乱，出错的机率会升高。
    $PUSH_DATABASE_PATH
    $PUSH_STORAGE_PATH
    ```

3. 运行下列指令，会根据`DJVoiceConfig.pm` 定义的路径修改各shell script。

    ```
    ./setup -p
    ```

4. 开始整理作品，将要建档的作品档案都放入目录里，假设在`/Users/hentai/myVoicePart1` 里，然后运行下列指令，建议分
多次处理，每次100个左右，被DLSite拉黑就不用玩了：

    ```
    ./buildVoiceWork.sh -s /Users/hentai/myVoicePart1
    ./buildVoiceWork.sh -s /Users/hentai/myVoicePart2
    ./buildVoiceWork.sh -s /Users/hentai/myVoicePart3
    ...
    ```

- 注1：资料库里有我已经建档3000+个作品的基本资料，所以不会全都从DLSite上捞，但封面每部作品都要捞，动作太密集有被
拉黑的可能。
- 注2： -s 是安静模式，此模式下`buildVoiceWork.sh` 不会做与wunderlist推播通知相关的运算。
- 注3：若不指定路径，`buildVoiceWork.sh` 预设会处理 `$JDOWNLOADER_DOWNLOAD_DIR`。


与 WunderList 协作
-----------------------

1. 本脚本利用wunderlist作为清单和推播介面，请注册两个帐号，一发一收。发送端要登入以下网址申请开发者帐号，并建立App：

   [https://developer.wunderlist.com/apps](https://developer.wunderlist.com/apps)

   建立App时会要求填入app url和callback url，随便填即可。建好后可拿到client id，
   再点右下角的“CREATE ACCESS TOKEN”按钮可再得到一组access token，记下这两组号码，于下个步骤填入`DJVoiceConfig.pm`。

   ![Image of Yaktocat](http://i.imgur.com/TW3IH8P.png)

2. 编辑`DJVoiceConfig.pm` 修改以下参数：

    ```
    $POP_DATABASE_PATH    # setup -w 会透过此参数找资料库
    $WUNDERLIST_TOKEN
    $WUNDERLIST_CLIENT_ID
    $WUNDERLIST_RECEIVER_EMAIL
    ```

3. 运行下列指令，完成后WunderList的接收端帐号会收到两个清单分享，选同意。

    ```
    ./setup -w
    ```

    两个清单分别为： ダウンロード(下载)，オススメ作品(推荐作品)，“ダウンロード”会在主机端处理新作品时用到；
    “オススメ作品” 则会在客户端的iTunes汇入作品时使用。

4. 运行下列指令，会在WunderList的推荐清单里填入符合条件的作品，第一次运行会比较花时间，而且有时会因为
   Wunderlist回应404导至脚本中止，多运行几次即可。：

    ```
    ./reflashRecommendList
    ```

- 注1：往后如果想设计自己的推荐清单，可以先修改 `@RECOMMEND_CRITERIA_ARRAY`，再运行`setup -w` ，過程会检查
  query 的语法，没问题才新增待办事项(task)。

- 注2：`setup -w`会改动`DJVoiceWorkConfig.pm`，除了安装时是先在主机端执行，再复制去客户端外，往后请在客户端
  作`setup -w`。

- 注3：可修改`DJVoiceConfig.pm` 的`$COLUMN_OF_RECOMMEND_LIST` 参数，增加清单长度。

安装客户端程式
-----------------------

1. 请确认客户端的预设解压缩程式，在完成解压缩后会删除压缩档，本程式依靠压缩档的消失来判断解压完成与否。

2. 将主机端的 `dj_voice_organize` 资料夹复制一份到客户端上，如果没有做主机／客户端配置，则跳至步骤3。

3. 编辑客户端的`DJVoiceConfig.pm` 根据你的环境修改以下参数：

    ```
    $WORKING_DIR
    $POP_STORAGE_PATH      # 以客户端为起点，指向与主机端$PUSH_STORAGE_PATH 所指的同一个资料夹 
    $POP_DATABASE_PATH     # 以客户端为起点，指向与主机端$PUSH_DATABASE_PATH 所指的同一个资料库 
    $ITUNES_PATH
    ```

4. 运行下列指令，会根据`DJVoiceConfig.pm` 定义的路径修改各shell script。

    ```
    ./setup -p
    ```

运行客户端程式
-----------------------

至此，已完成初步配置了，本程式在客户端提供下列指令：

  下载RJ123456，RJ789012到客户端，并汇入到iTunes，-d 是下载的意思：

  ```
  ./downloadVoiceWork.sh -d RJ123456 RJ789012 ...
  ```

  没有指定作品时，将下载WunderList里被勾选的作品，并汇入到iTunes：

  ```
  ./downloadVoiceWork.sh -d
  ```

  没有 `-d` 时，仅计算被勾选的作品需要的空间，不下载：

  ```
  ./downloadVoiceWork.sh
  ./downloadVoiceWork.sh RJ123456 RJ789012 ...
  ```

  曾经汇入iTunes的作品将会在资料库里作标记，将被略过，除非在指令里加 `-f` ，可强制下载：

  ```
  ./downloadVoiceWork.sh -f -d RJ123456 RJ789012 ...
  ```

`downloadVoiceWork.sh`会在汇入iTunes后顺带执行`reflashRecommendList`更新推荐清单。


与JDownloader 2 协作
-----------------------

1. 本程式可以配合JDownloader 2 监控下载路径，过滤所有档名含有RJ######的压缩档，下载完成自动整理进资料库，
并筛选出你有兴趣的作品做手机的推播通知。


2. 编辑主机端的`DJVoiceConfig.pm` 根据你的喜好修改以下参数：

    ```
    $NOTIFY_DEFAULT_THRESHOLD
    %NOTIFY_CRITERIA_HASH_VOCAL
    %NOTIFY_CRITERIA_HASH_HOLD_TAG
    %NOTIFY_CRITERIA_HASH_PASS_TAG
    %NOTIFY_CRITERIA_HASH_CIRCLE
    ```

   新作品的推播筛选，是根据发行社团，属性标签，声优决定的。三者决定一个阀值，当下载数大于阀值则发
   送推播通知。
   计算阀值规则如下：

       缺省值(DEFAULT) ------------\
       喜好的属性标签(PASS_TAG) ---取最小值----
       声优(VOCAL) ----------------/           \
                                                \
       讨厌的属性标签(HOLD_TAG) -------------取最大值------
                                                           \
       发行社团(CIRCLE) ---------------------------------取最小值

3. 开启Jdownloader 2 的script 功能，加入下列代码：

    ```
    //Add your script here. Feel free to use the available api properties and methods
    var script = '/你/的/路/径/dj_voice_organize/jdFinishEventHandler.sh'

    //var path = archive.getFolder()
    //var name = archive.getName()
    //var label = archive.getDownloadLinks() && archive.getDownloadLinks()[0].getPackage().getComment() ? archive.getDownloadLinks()[0].getPackage().getComment() : 'N/A'

    //var command = [script, path, name, label, 'ARCHIVE_EXTRACTED']
    var command = [script]

    log(command)
    log(callSync(command))
    ```

4. 代码的触发条件我是选Package Finished，如果你是因为压缩档有密码想让JDownloader2 做解压缩，
可选Archive Extraction Finished。

与 FlexGet 协作
-----------------------
为避免过多的爬虫程式对网站造成攻击，我只列出使用爬虫脚本的必要条件：

1. 修改`DJVoiceConfig.pm` ：

    ```
    $JDOWNLOADER_WATCH_DIR  # Jdownloader 2 监控的资料夹，放入.crawjob 就会新增下载任务
    $USING_FLEXGET           # 设为1
    ```

2. FlexGet 的 exec 需完成以下几项工作：

    - 在 Jdownloader 2 监控的资料夹，放入.crawjob 就会新增下载任务

    - 检查资料库里是否已有重复的作品，栏位`read = 0`或没有id相符合的作品才下载
    
    - 每当开始新的下载任务，请对资料库下这条指令：

        ```
          UPDATE JDownLoadVar SET value = 1 WHERE name = 'voiceWorkTrigger';
        ```


给开发者：
-----------------------
1. 下列议题如果有开发者完成，我会用 1.77 TB 的资料回报：

    - 我的系统是OSX，本程式若要在其它作业系统上运行，必需做修改，完成者，重谢。

    - 我的环境是在写这个脚本的过程里逐渐完备的，写这文件时对如何安装atomicparsley，eyeD3，fdk-aac，gnu-sed，
    perl各模组等都只能凭记忆写，如果有高手能写一个安装这些协作软件的脚本，重谢。

    - Wunderlist被Mircrsoft买断，可能在一到两年内停止服务，所以我写到相关的功能都是用简单的curl呼叫，没有包装，
    如果有高手能用ticktick，Microsoft to-do或任何适合的app取代，重谢。

2. 任何有用的小修小改，我都会以我正在用的爬虫脚本做回报，不是多难的脚本，但爬虫脚本用的人多了，或太频繁
的刷新，网站就会防，然后我就得改，所以只给懂程式的人。


