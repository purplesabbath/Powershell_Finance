# 
# 年份列表
$year_list = @(
    "2024-03-31",
    "2023-12-31","2023-09-30","2023-06-30","2023-03-31",
    "2022-12-31","2022-09-30","2022-06-30","2022-03-31",
    "2021-12-31","2021-09-30","2021-06-30","2021-03-31",
    "2020-12-31","2020-09-30","2020-06-30","2020-03-31",
    "2019-12-31","2019-09-30","2019-06-30","2019-03-31",
    "2018-12-31","2018-09-30","2018-06-30","2018-03-31",
    "2017-12-31","2017-09-30","2017-06-30","2017-03-31",
    "2016-12-31","2016-09-30","2016-06-30","2016-03-31",
    "2015-12-31","2015-09-30","2015-06-30","2015-03-31",
    "2014-12-31","2014-09-30","2014-06-30","2014-03-31",
    "2013-12-31","2013-09-30","2013-06-30","2013-03-31",
    "2012-12-31","2012-09-30","2012-06-30","2012-03-31",
    "2011-12-31","2011-09-30","2011-06-30","2011-03-31",
    "2010-12-31","2010-09-30","2010-06-30","2010-03-31"
)


# 定义请求头与Cookies等
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
$session.Cookies.Add((New-Object System.Net.Cookie("qgqp_b_id", "c202da2873d35b7d6f5aa6ec7776fec1", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("websitepoptg_api_time", "1714225708805", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_si", "44701323415612", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_asi", "delete", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("HAList", "ty-1-688819-%u5929%u80FD%u80A1%u4EFD%2Cty-0-300059-%u4E1C%u65B9%u8D22%u5BCC%2Cty-1-600028-%u4E2D%u56FD%u77F3%u5316%2Cty-1-600007-%u4E2D%u56FD%u56FD%u8D38%2Cty-1-601601-%u4E2D%u56FD%u592A%u4FDD%2Cty-0-000503-%u56FD%u65B0%u5065%u5EB7%2Cty-0-002777-%u4E45%u8FDC%u94F6%u6D77%2Cty-0-002589-%u745E%u5EB7%u533B%u836F%2Cty-1-600276-%u6052%u745E%u533B%u836F%2Cty-0-000001-%u5E73%u5B89%u94F6%u884C", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_pvi", "41441313521449", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sp", "2023-09-18%2010%3A55%3A07", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_inirUrl", "https%3A%2F%2Fcn.bing.com%2F", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_sn", "9", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("st_psi", "20240427220410643-113300301066-2383266015", "/", ".eastmoney.com")))
$session.Cookies.Add((New-Object System.Net.Cookie("JSESSIONID", "F7DD557DEEA4AE1A1D327759B879A079", "/", "datacenter-web.eastmoney.com")))


# 爬取从2010一季度~2024一季度所有上市公视的业绩报表数据
foreach ($this_seaon in $year_list) {
    $page = 1            # 设定起始页数
    $line_count = 500    # 设定页行数
    # 按照每页500行导出，如果当年前页面少于500行则停止导出
    while ($line_count -eq 500) {
        $req_url = "https://datacenter-web.eastmoney.com/api/data/v1/get?callback=jQuery112307327744516705901_1714226663034&sortColumns=UPDATE_DATE%2CSECURITY_CODE&sortTypes=-1%2C-1&pageSize=500&pageNumber=$page&reportName=RPT_LICO_FN_CPD&columns=ALL&filter=(REPORTDATE%3D%27$this_seaon%27)"
        $res = Invoke-WebRequest -UseBasicParsing -Uri $req_url `
        -WebSession $session `
        -Headers @{
        "Accept"="*/*"
            "Accept-Encoding"="gzip, deflate, br, zstd"
            "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
            "Referer"="https://data.eastmoney.com/bbsj/yjbb.html"
            "Sec-Fetch-Dest"="script"
            "Sec-Fetch-Mode"="no-cors"
            "Sec-Fetch-Site"="same-site"
            "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
            "sec-ch-ua-mobile"="?0"
            "sec-ch-ua-platform"="`"Windows`""
        }
        
        # 将K线数据中爬虫返回的结果中取出（以JSON的格式）
        $finance_str = [regex]::matches($res.Content, '(?<=.data..).*?(?=..count)')
        # 保存为本地JSON文件
        $path = "D:\MyScript\ps\stock_finance\finance" + "_" + $this_seaon + "_" + $page + ".json"
        $line_count = ($finance_str | ConvertFrom-Json).length    # 返回的文件长度
        $page += 1
        $finance_str.Value | Out-File $path
        write-host $this_seaon + ": " $page + 'is download!!!'
    }
}


# 发起请求(目前沪深总共3602)，由于网页限制每次只能爬500条，需要分多页导出
# foreach ($page in 1..[Math]::Ceiling(3602/500)) {
#     $res = Invoke-WebRequest -UseBasicParsing -Uri $req_url `
#     -WebSession $session `
#     -Headers @{
#     "Accept"="*/*"
#         "Accept-Encoding"="gzip, deflate, br, zstd"
#         "Accept-Language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
#         "Referer"="https://data.eastmoney.com/bbsj/yjbb.html"
#         "Sec-Fetch-Dest"="script"
#         "Sec-Fetch-Mode"="no-cors"
#         "Sec-Fetch-Site"="same-site"
#         "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
#         "sec-ch-ua-mobile"="?0"
#         "sec-ch-ua-platform"="`"Windows`""
#     }
    
#     # 将K线数据中爬虫返回的结果中取出（以JSON的格式）
#     $finance_str = [regex]::matches($res.Content, '(?<=.data..).*?(?=..count)')
#     # 保存为本地JSON文件
#     $path = "D:\MyScript\ps\stock_finance\finance" + $page + ".json"
#     $finance_str.Value | Out-File $path
#     write-host $page + 'is download!!!'
# }