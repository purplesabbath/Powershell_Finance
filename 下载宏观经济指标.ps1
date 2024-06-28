# 爬取经济指标==============================================

# 构造时间戳
$t = (([DateTime]::Now.ToUniversalTime().Ticks - 621355968000000000)/10000000).tostring().Substring(0,13)


# 构造请求
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
$session.Cookies.Add((New-Object System.Net.Cookie("qgqp_b_id", "c202da2873d35b7d6f5aa6ec7776fec1", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("HAList", "ty-0-000014-%u6C99%u6CB3%u80A1%u4EFD%2Cty-0-000019-%u6DF1%u7CAE%u63A7%u80A1%2Cty-1-688819-%u5929%u80FD%u80A1%u4EFD%2Cty-0-300059-%u4E1C%u65B9%u8D22%u5BCC%2Cty-1-600028-%u4E2D%u56FD%u77F3%u5316%2Cty-1-600007-%u4E2D%u56FD%u56FD%u8D38%2Cty-1-601601-%u4E2D%u56FD%u592A%u4FDD%2Cty-0-000503-%u56FD%u65B0%u5065%u5EB7%2Cty-0-002777-%u4E45%u8FDC%u94F6%u6D77%2Cty-0-002589-%u745E%u5EB7%u533B%u836F", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("websitepoptg_api_time", "1715320212278", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_si", "77873087912042", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_asi", "delete", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_pvi", "41441313521449", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sp", "2023-09-18%2010%3A55%3A07", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_inirUrl", "https%3A%2F%2Fcn.bing.com%2F", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sn", "14", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_psi", "2024051013533368-0-1578566228", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "1FE920771143BE487BC6B379734204B8", "/", "datacenter-web.eastmoney.com")))

$res = Invoke-WebRequest -UseBasicParsing -Uri "https://datacenter-web.eastmoney.com/api/data/v1/get?callback=jQuery112302734301871168743_1715320470107&columns=REPORT_DATE%2CNATIONAL_BASE%2CCITY_BASE%2CRURAL_BASE&sortColumns=REPORT_DATE&sortTypes=-1&source=WEB&client=WEB&reportName=RPT_ECONOMY_CPI&_=1715320470108" `
-WebSession $session `
-Headers @{
    "Accept"="*/*"
    "Accept-Encoding"="gzip, deflate, br, zstd"
    "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
    "Referer"="https://data.eastmoney.com/cjsj/cpi.html"
    "Sec-Fetch-Dest"="script"
    "Sec-Fetch-Mode"="no-cors"
    "Sec-Fetch-Site"="same-site"
    "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
    "sec-ch-ua-mobile"="?0"
    "sec-ch-ua-platform"="`"Windows`""
}

$res.Content | ConvertFrom-Json | Out-File ""