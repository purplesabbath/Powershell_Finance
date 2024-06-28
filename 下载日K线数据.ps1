#NOTE - 从腾讯财经爬取日K
function daily_kline_from_qq($save_path) {
    # 构造时间戳
    $t = (([DateTime]::Now.ToUniversalTime().Ticks - 621355968000000000)).tostring().Substring(0,17)
    # 待下载股票列表(全部上证)
    $stock_list = Get-Content "D:\MyScript\ps\custom\上证股票列表.txt"

    # 构造请求头
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
    $session.Cookies.Add((New-Object System.Net.Cookie("RK", "yGmhHoRI6r", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ptcz", "76c2f59fed495ec616bd27dec8c7b636d1989b0f46b7227c434ef8ca5703b347", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("iip", "0", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("qq_domain_video_guid_verify", "7a8e9c7f4b3a7944", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("pgv_pvid", "8929797020", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("tvfe_boss_uuid", "dde4f6cb59b1fe2b", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("eas_sid", "G116F9G8F1u388u1s5C3I8k6B1", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("fqm_pvqid", "fa392fb6-d3bb-4cb4-976d-849f457bf0b5", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_qimei_q36", "", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_qimei_h38", "e147f8e170f4a6a16ea55b1d02000005817a14", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_qimei_fingerprint", "9c70d7af99420eb0064c067ba3da8cd6", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("_qimei_uuid42", "181080a3a151003c5e35eab05c7b725981801763fb", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("pac_uid", "1_2643776446", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("suid", "ek169232732982549945", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ptui_loginuin", "2643776446", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("RECENT_CODE", "601318_1", "/", ".qq.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("tgw_l7_route", "828a5882b971e2243f84bb78f7d7c600", "/", "proxy.finance.qq.com")))

    # 逐个爬取各个股票的数据
    foreach ($stock_code in $stock_list) {
        # 要请求的链接
        $url = "https://proxy.finance.qq.com/ifzqgtimg/appstock/app/newfqkline/get?_var=kline_dayqfq&param=sh$stock_code,day,,,1800,qfq&r=0.$t"
        # 请求返回的结果
        $res = Invoke-WebRequest -UseBasicParsing -Uri $url `
        -WebSession $session `
        -Headers @{
            "Accept"="*/*"
            "Accept-Encoding"="gzip, deflate, br, zstd"
            "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
            "Referer"="https://gu.qq.com/"
            "Sec-Fetch-Dest"="script"
            "Sec-Fetch-Mode"="no-cors"
            "Sec-Fetch-Site"="same-site"
            "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
            "sec-ch-ua-mobile"="?0"
            "sec-ch-ua-platform"="`"Windows`""
        }

        # 正则表达式提取数据
        $kline_str = ([regex]::Matches($res.Content, "(?<=.qfqday..).*?(?=,.qt)")).Value.replace("[", "@(").replace("]",")") -replace "{.*?}", "`"-`""
        $kline = Invoke-Expression "@($kline_str)"

        # 初始化数据表
        $data = New-Object System.Data.DataTable

        # 设定数据表中的列名与数据类型
        $col0 = New-Object System.Data.DataColumn Name, ([string])
        $col1 = New-Object System.Data.DataColumn Date, ([string])
        $col2 = New-Object System.Data.DataColumn Open, ([string])
        $col3 = New-Object System.Data.DataColumn High, ([string])
        $col4 = New-Object System.Data.DataColumn Low, ([string])
        $col5 = New-Object System.Data.DataColumn Close, ([string])
        $col6 = New-Object System.Data.DataColumn Volume, ([string])
        $col7 = New-Object System.Data.DataColumn Unkown, ([string])
        $col8 = New-Object System.Data.DataColumn Range, ([string])
        $col9 = New-Object System.Data.DataColumn TradeValue, ([string])
        
        $data.Columns.Add($col0)
        $data.Columns.Add($col1)
        $data.Columns.Add($col2)
        $data.Columns.Add($col3)
        $data.Columns.Add($col4)
        $data.Columns.Add($col5)
        $data.Columns.Add($col6)
        $data.Columns.Add($col7)
        $data.Columns.Add($col8)
        $data.Columns.Add($col9)

        # 将数据添加到数据表中
        foreach ($d in $kline) {
            $tmp = $d -split ","
            $row = $data.NewRow()
            $total_col = @("Date", "Open", "High", "Low", "Close", "Volume", "Unkown", "Range", "TradeValue")
            $row["Name"] = $stock_code
            for ($i=0; $i -lt $total_col.Length; $i++) {
                $row[$total_col[$i]] = $tmp[$i]
            }
            $data.rows.Add($row)
        }
        $data | ConvertTo-Csv | Out-File "$save_path\$stock_code.csv"
        Write-Host $stock_code
    }

    Write-Host "All stock dayily klines is download"
}

# daily_kline_from_qq "D:\MyScript\ps\stock_daily_k"


#NOTE - 从上证交易所数据中心获取日K
function daily_kline_from_sse($save_path) {
    # 时间戳
    $stock_list = Get-Content "D:\MyScript\ps\custom\上证股票列表.txt"
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
    $session.Cookies.Add((New-Object System.Net.Cookie("gdp_user_id", "gioenc-542ed44c%2Cc461%2C5680%2Cc525%2C038gga40e929", "/", ".sse.com.cn")))
    $session.Cookies.Add((New-Object System.Net.Cookie("VISITED_MENU", "%5B%228527%22%2C%228451%22%5D", "/", ".sse.com.cn")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ba17301551dcbaf9_gdp_session_id", "a9170c0a-2c79-4926-9fdb-8bacbe783985", "/", ".sse.com.cn")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ba17301551dcbaf9_gdp_session_id_sent", "a9170c0a-2c79-4926-9fdb-8bacbe783985", "/", ".sse.com.cn")))
    $session.Cookies.Add((New-Object System.Net.Cookie("ba17301551dcbaf9_gdp_sequence_ids", "{%22globalKey%22:76%2C%22VISIT%22:4%2C%22PAGE%22:13%2C%22VIEW_CLICK%22:60%2C%22VIEW_CHANGE%22:2}", "/", ".sse.com.cn")))

    foreach ($stock_code in $stock_list) {
        $t = (([DateTime]::Now.ToUniversalTime().Ticks - 621355968000000000)).tostring().Substring(0,13)
        $url = "https://yunhq.sse.com.cn:32042/v1/sh1/dayk/" + $stock_code + "?callback=jQuery112402890740402226786_1716027832704&begin=-1800&end=-1&period=day&_=$t"
        $res = Invoke-WebRequest -UseBasicParsing -Uri $url `
        -WebSession $session `
        -Headers @{
        "Accept"="*/*"
        "Accept-Encoding"="gzip, deflate, br, zstd"
        "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
        "Referer"="https://www.sse.com.cn/"
        "Sec-Fetch-Dest"="script"
        "Sec-Fetch-Mode"="no-cors"
        "Sec-Fetch-Site"="same-site"
        "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
        "sec-ch-ua-mobile"="?0"
        "sec-ch-ua-platform"="`"Windows`""
        }

        # 正则表达式提取数据
        $kline_str = ([regex]::Matches($res.Content, "(?<=kline..).*?(]])")).Value.replace("[", "@(").replace("]",")")
        $kline = Invoke-Expression "@($kline_str)"

        # 初始化数据表
        $data = New-Object System.Data.DataTable

        # 设定数据表中的列名与数据类型
        $col0 = New-Object System.Data.DataColumn Name, ([string])
        $col1 = New-Object System.Data.DataColumn Date, ([string])
        $col2 = New-Object System.Data.DataColumn Open, ([string])
        $col3 = New-Object System.Data.DataColumn High, ([string])
        $col4 = New-Object System.Data.DataColumn Low, ([string])
        $col5 = New-Object System.Data.DataColumn Close, ([string])
        $col6 = New-Object System.Data.DataColumn Volume, ([string])
        $col7 = New-Object System.Data.DataColumn TradeValue, ([string])
        
        $data.Columns.Add($col0)
        $data.Columns.Add($col1)
        $data.Columns.Add($col2)
        $data.Columns.Add($col3)
        $data.Columns.Add($col4)
        $data.Columns.Add($col5)
        $data.Columns.Add($col6)
        $data.Columns.Add($col7)

        # 将数据添加到数据表中
        foreach ($d in $kline) {
            $tmp = $d -split ","
            $row = $data.NewRow()
            $total_col = @("Date", "Open", "High", "Low", "Close", "Volume", "TradeValue")
            $row["Name"] = $stock_code
            for ($i=0; $i -lt $total_col.Length; $i++) {
                $row[$total_col[$i]] = $tmp[$i]
            }
            $data.rows.Add($row)
        }
        $data | ConvertTo-Csv | Out-File "save_path\$stock_code.csv"
        Write-Host $stock_code
    }
    Write-Host "All stock daily klines is download"
}










