# 爬取所有沪深股票的指标（市盈率、市现率等）==================================================
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
$session.Cookies.Add((New-Object System.Net.Cookie("qgqp_b_id", "c202da2873d35b7d6f5aa6ec7776fec1", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("HAList", "ty-0-000014-%u6C99%u6CB3%u80A1%u4EFD%2Cty-0-000019-%u6DF1%u7CAE%u63A7%u80A1%2Cty-1-688819-%u5929%u80FD%u80A1%u4EFD%2Cty-0-300059-%u4E1C%u65B9%u8D22%u5BCC%2Cty-1-600028-%u4E2D%u56FD%u77F3%u5316%2Cty-1-600007-%u4E2D%u56FD%u56FD%u8D38%2Cty-1-601601-%u4E2D%u56FD%u592A%u4FDD%2Cty-0-000503-%u56FD%u65B0%u5065%u5EB7%2Cty-0-002777-%u4E45%u8FDC%u94F6%u6D77%2Cty-0-002589-%u745E%u5EB7%u533B%u836F", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("websitepoptg_api_time", "1715181041797", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_si", "65349807563904", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_asi", "delete", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "C619B96C8A0D661BCEE620840AD7ACDB", "/", "datacenter-web.eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_pvi", "41441313521449", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sp", "2023-09-18%2010%3A55%3A07", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_inirUrl", "https%3A%2F%2Fcn.bing.com%2F", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sn", "4", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_psi", "20240508231108738-113300303062-4470300498", "/", ".eastmoney.com")))

# 数据截至的日期
$now_date = "2024-05-08"
$page = 1            # 设定起始页数
$line_count = 500    # 设定页行数

while ($line_count -eq 500) {
    # 需要爬取的数据链接
    $req_url = "https://datacenter-web.eastmoney.com/api/data/v1/get?callback=jQuery1123019799760594635196_1715181208851&sortColumns=SECURITY_CODE&sortTypes=1&pageSize=$line_count&pageNumber=$page&reportName=RPT_VALUEANALYSIS_DET&columns=ALL&quoteColumns=&source=WEB&client=WEB&filter=(TRADE_DATE%3D%27$now_date%27)"
    # 发起请求
    $res = Invoke-WebRequest -UseBasicParsing -Uri $req_url `
    -WebSession $session `
    -Headers @{
    "Accept"="*/*"
    "Accept-Encoding"="gzip, deflate, br, zstd"
    "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
    "Referer"="https://data.eastmoney.com/gzfx/list.html"
    "Sec-Fetch-Dest"="script"
    "Sec-Fetch-Mode"="no-cors"
    "Sec-Fetch-Site"="same-site"
    "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
    "sec-ch-ua-mobile"="?0"
    "sec-ch-ua-platform"="`"Windows`""
    }
    
    # 正则表达式提取数据文本
    $index_str = [regex]::matches($res.Content, '(?<=.data..).*?(?=..count)')
    # 保存为本地JSON文件
    $path = "D:\MyScript\ps\stock_index\" + "stock_index" +$page + ".json"
    $line_count = ($index_str | ConvertFrom-Json).length    # 返回的文件长度
    $index_str.Value | Out-File $path
    write-host "page" + $page + ' is download!!!'
    $page += 1
}

