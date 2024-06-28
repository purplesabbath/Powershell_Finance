# 构造时间戳(10位时间戳)
$t = (([DateTime]::Now.ToUniversalTime().Ticks - 621355968000000000)/10000000).tostring().Substring(0,10)

# 待下载股票列表(全部上证)
$stock_list = Get-Content "D:\MyScript\ps\custom\上证股票列表.txt"

foreach ($stock_code in $stock_list) {
  # 股票代码
  $stock_code = "sh" + $stock_code
  # 需要爬取的链接
  $url = "https://quotes.sina.cn/cn/api/openapi.php/CompanyFinanceService.getFinanceReport2022?paperCode=$stock_code&source=gjzb&type=0&page=1&num=10&callback=hqccall$t"
  # 构造请求头
  $header = @{
    "authority"="quotes.s ina.cn"
    "method"="GET"
    "path"="/cn/api/openapi.php/CompanyFinanceService.getFinanceReport2022?paperCode=$stock_code&source=gjzb&type=0&page=1&num=10&callback=hqccall$t"
    "scheme"="https"
    "accept"="*/*"
    "accept-encoding"="gzip, deflate, br, zstd"
    "accept-language"="zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6"
    "referer"="https://vip.stock.finance.sina.com.cn/"
    "sec-ch-ua"="`"Chromium`";v=`"124`", `"Microsoft Edge`";v=`"124`", `"Not-A.Brand`";v=`"99`""
    "sec-ch-ua-mobile"="?0"
    "sec-ch-ua-platform"="`"Windows`""
    "sec-fetch-dest"="script"
    "sec-fetch-mode"="no-cors"
    "sec-fetch-site"="cross-site"
  }

  $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
  $session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0"
  $res = Invoke-WebRequest -UseBasicParsing -Uri $url -WebSession $session -Headers $header

  # 正则表达式提取出财报内容
  $finance_string = [regex]::matches($res.Content, '({\Sresult).*?(}}}}})') | ConvertFrom-Json

  # 初始化数据表(定义数据表的列)
  $year_report = New-Object System.Data.DataTable
  $col_name = New-Object System.Data.DataColumn item_corporate, ([string])
  $col_time = New-Object System.Data.DataColumn item_time, ([string])
  $col0 = New-Object System.Data.DataColumn item_field, ([string])
  $col1 = New-Object System.Data.DataColumn item_title, ([string])
  $col2 = New-Object System.Data.DataColumn item_value, ([string])
  $col3 = New-Object System.Data.DataColumn item_display_type, ([string])
  $col4 = New-Object System.Data.DataColumn item_display, ([string])
  $col5 = New-Object System.Data.DataColumn item_precision, ([string])
  $col6 = New-Object System.Data.DataColumn item_source, ([string])
  $col7 = New-Object System.Data.DataColumn item_number, ([string])
  $col8 = New-Object System.Data.DataColumn item_group_no, ([string])
  $col9 = New-Object System.Data.DataColumn item_tongbi, ([string])

  $year_report.Columns.Add($col_name)
  $year_report.Columns.Add($col_time)
  $year_report.Columns.Add($col0)
  $year_report.Columns.Add($col1)
  $year_report.Columns.Add($col2)
  $year_report.Columns.Add($col3)
  $year_report.Columns.Add($col4)
  $year_report.Columns.Add($col5)
  $year_report.Columns.Add($col6)
  $year_report.Columns.Add($col7)
  $year_report.Columns.Add($col8)
  $year_report.Columns.Add($col9)

  # 有多少期财报
  $report_period = $finance_string.result.data.report_list | 
      Get-Member | 
      Where-Object {$_.MemberType -eq "NoteProperty"} | 
      Select-Object -Property Name

  # 遍历每期财报
  foreach ($period in $report_period) {
    # 财报期数
    $num_priod = $period.Name.ToString()
    $f_data = $finance_string.result.data.report_list | 
      Select-Object -ExpandProperty $num_priod | 
      Select-Object -Property data

    # 将JSON样式的数据转为表格样式的dataTbale
    foreach ($ind in 0..($f_data.data.Length-1)) {
      $row = $year_report.NewRow()
      $row["item_corporate"] = $stock_code
      $row["item_time"] = $num_priod
      foreach ($i in @("item_field", "item_title", "item_value", "item_display_type", "item_display", "item_precision", "item_source", "item_number", "item_group_no", "item_tongbi")) {
        try {
          $row[$i] = ($f_data.data[$ind] | Select-Object -ExpandProperty $i).tostring()
        } 
        catch [System.Management.Automation.RuntimeException] {
          # 输出错误的内容的位置
          # write-host "Wrong in => " + $num_priod " => " + $ind + " => " + $i
          $row[$i] = ""
        }
      }
      $year_report.rows.Add($row)
    }
  }

  $year_report | ConvertTo-Csv | Out-File "D:\MyScript\ps\stock_financial_report\$stock_code.csv"

  Write-Host "股票: $stock_code is download!!!"

}



