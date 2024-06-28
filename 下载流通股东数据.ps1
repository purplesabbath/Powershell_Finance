# 构造请求头
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
$session.Cookies.Add((New-Object System.Net.Cookie("qgqp_b_id", "c202da2873d35b7d6f5aa6ec7776fec1", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("emshistory", "%5B%22%E6%8B%9B%E5%95%86%22%5D", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("HAList", "ty-1-600036-%u62DB%u5546%u94F6%u884C%2Cty-0-300459-%u6C64%u59C6%u732B%2Cty-1-603259-%u836F%u660E%u5EB7%u5FB7%2Cty-0-000503-%u56FD%u65B0%u5065%u5EB7%2Cty-1-688235-%u767E%u6D4E%u795E%u5DDE-U%2Cty-1-600155-%u534E%u521B%u4E91%u4FE1%2Cty-0-000014-%u6C99%u6CB3%u80A1%u4EFD%2Cty-0-000019-%u6DF1%u7CAE%u63A7%u80A1%2Cty-1-688819-%u5929%u80FD%u80A1%u4EFD%2Cty-0-300059-%u4E1C%u65B9%u8D22%u5BCC", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("websitepoptg_api_time", "1715810000268", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_si", "20903877166903", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_asi", "delete", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_pvi", "41441313521449", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sp", "2023-09-18%2010%3A55%3A07", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_inirUrl", "https%3A%2F%2Fcn.bing.com%2F", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sn", "24", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_psi", "20240516131800367-113300300975-4543227299", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "CB95DBC4072A10DEE578DDD66679AB7E", "/", "datacenter-web.eastmoney.com")))

# 每页的行数，起始页数，日期
$pageSize = 500
$pageNumber = 1
$date = "2024-03-31"

# 循环下载每一页
while ($pageSize -eq 500) {
    # 要爬取的URL
    $url = "https://datacenter-web.eastmoney.com/api/data/v1/get?callback=jQuery112309001326101258529_1715836680224&sortColumns=UPDATE_DATE%2CSECURITY_CODE%2CHOLDER_RANK&sortTypes=-1%2C1%2C1&pageSize=$pageSize&pageNumber=$pageNumber&reportName=RPT_F10_EH_FREEHOLDERS&columns=ALL&source=WEB&client=WEB&filter=(END_DATE%3E%3D%27$date%27)"
    $res = Invoke-WebRequest -UseBasicParsing -Uri $url `
    -WebSession $session `
    -Headers @{
        "Accept"="*/*"
        "Accept-Encoding"="gzip, deflate, br, zstd"
        "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
        "Referer"="https://data.eastmoney.com/gdfx/HoldingDetail.html"
        "Sec-Fetch-Dest"="script"
        "Sec-Fetch-Mode"="no-cors"
        "Sec-Fetch-Site"="same-site"
        "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
        "sec-ch-ua-mobile"="?0"
        "sec-ch-ua-platform"="`"Windows`""
    }
    # 正则表达式提取结果(这里对正则表达式进行了优化，由于有些公司的名称里可能会带有account，这里在正则表达式中加了":"，数据未被提取完)
    $index_str = [regex]::matches($res.Content, '(?<=.data..).*?(?=..count.:)')
    # 保存为本地JSON文件
    $path = "D:\MyScript\ps\stock_shareholders\" + "stock_shareholders" +$pageNumber + ".json"
    $pageSize = ($index_str | ConvertFrom-Json).length    # 返回的文件长度
    $index_str.Value | Out-File $path
    write-host "page" + $pageNumber + ' is download!!!'
    $pageNumber += 1
}