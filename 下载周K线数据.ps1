
# 时间戳
$t = (([DateTime]::Now.ToUniversalTime().Ticks - 621355968000000000)/10000000).tostring().Substring(0,13)

# 待下载股票列表(全部上证)
$stock_list = Get-Content "D:\MyScript\ps\custom\上证股票列表.txt"

# 逐个爬取各个股票的数据
foreach ($stock_code in $stock_list) {
    # 开始爬虫
    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
    $session.Cookies.Add((New-Object System.Net.Cookie("qgqp_b_id", "c202da2873d35b7d6f5aa6ec7776fec1", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("HAList", "ty-1-601601-%u4E2D%u56FD%u592A%u4FDD%2Cty-0-000503-%u56FD%u65B0%u5065%u5EB7%2Cty-0-002777-%u4E45%u8FDC%u94F6%u6D77%2Cty-0-002589-%u745E%u5EB7%u533B%u836F%2Cty-1-600276-%u6052%u745E%u533B%u836F%2Cty-0-300059-%u4E1C%u65B9%u8D22%u5BCC%2Cty-0-000001-%u5E73%u5B89%u94F6%u884C%2Cty-1-000001-%u4E0A%u8BC1%u6307%u6570%2Cty-0-000100-TCL%u79D1%u6280", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("websitepoptg_api_time", "1714051875861", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_si", "09131096976917", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_pvi", "41441313521449", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_sp", "2023-09-18%2010%3A55%3A07", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_inirUrl", "https%3A%2F%2Fcn.bing.com%2F", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_sn", "6", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_psi", "20240425213433929-113200322732-8736664264", "/", ".eastmoney.com")))
    $session.Cookies.Add((New-Object System.Net.Cookie("st_asi", "delete", "/", ".eastmoney.com")))

    $res = Invoke-WebRequest -UseBasicParsing -Uri "https://push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery35103004733920672322_1714052019416&secid=1.$stock_code&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1%2Cf2%2Cf3%2Cf4%2Cf5%2Cf6&fields2=f51%2Cf52%2Cf53%2Cf54%2Cf55%2Cf56%2Cf57%2Cf58%2Cf59%2Cf60%2Cf61&klt=102&fqt=1&end=20500101&lmt=120&_=$t" `
        -WebSession $session `
        -Headers @{
            "Accept"="*/*"
            "Accept-Encoding"="gzip, deflate, br, zstd"
            "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
            "Referer"="https://quote.eastmoney.com/sh$stock_code.html"
            "Sec-Fetch-Dest"="script"
            "Sec-Fetch-Mode"="no-cors"
            "Sec-Fetch-Site"="same-site"
            "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
            "sec-ch-ua-mobile"="?0"
            "sec-ch-ua-platform"="`"Windows`""
        }

    # 将K线数据中爬虫返回的结果中取出
    $kline_str = [regex]::matches($res.Content, '(?<=\[).*?(?=\])') | 
        Select-Object -Property Value | Select-Object -Property Value
    # 通过eval的方式将字符串转为数组
    $kline = Invoke-Expression "@($kline_str)" | Select-Object -Property Value

    # 初始化数据表
    $data = New-Object System.Data.DataTable
    # 设定数据表中的列名与数据类型
    $col0 = New-Object System.Data.DataColumn Name, ([string])
    $col1 = New-Object System.Data.DataColumn Date, ([string])
    $col2 = New-Object System.Data.DataColumn Open, ([float])
    $col3 = New-Object System.Data.DataColumn Close, ([float])
    $col4 = New-Object System.Data.DataColumn High, ([float])
    $col5 = New-Object System.Data.DataColumn Low, ([float])
    $col6 = New-Object System.Data.DataColumn ChangePercent, ([float])
    $col7 = New-Object System.Data.DataColumn ChangePrice, ([float])
    $col8 = New-Object System.Data.DataColumn Volume, ([float])
    $col9 = New-Object System.Data.DataColumn Value, ([float])
    $col10 = New-Object System.Data.DataColumn Range, ([float])
    $col11 = New-Object System.Data.DataColumn TurnOver, ([float])
    
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
    $data.Columns.Add($col10)
    $data.Columns.Add($col11)

    # 将数据添加到数据表中
    foreach ($d in $kline.Value) {
        $tmp = $d -split ","
        $row = $data.NewRow()
        $total_col = @("Date", "Open", "Close", "High", "Low", "ChangePercent", "ChangePrice", "Volume", "Value", "Range", "TurnOver")
        $row["Name"] = $stock_code
        for ($i=0; $i -lt $total_col.Length; $i++) {
            $row[$total_col[$i]] = $tmp[$i]
        }
        $data.rows.Add($row)
    }

    # 以为CSV格式保存到本地
    $data | ConvertTo-Csv | Out-File "D:\MyScript\ps\stock_weekly_k\\$stock_code.csv"
    Write-Host $stock_code
}

Write-Host "All stock weekly klines is download"