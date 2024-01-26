import pandas as pd
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import time
import requests

#設定 Chrome Driver 的執行檔路徑
options = Options()
options.add_experimental_option('excludeSwitches', ['enable-logging'])
options.chrome_executable_path="C:\\Users\\frank\\商旅險爬蟲\\chrome.exe"
#建立 Driver 物件實體，用應用程式操作瀏覽器瀏覽
driver = webdriver.Chrome(options=options)
# 連線到 1111
driver.get('https://www.1111.com.tw/search/corp')

# banner的高度
banner_height = 5000
# 每次滾動的像素
scroll_increment = 5000
# 在banner上方留出的空間加上晃動的像素
offset = 200

# 滾動時間限制（例如：60秒）
scroll_time_limit = 1800  # 1800秒
start_time = time.time()

# 滚动到达时间限制
while (time.time() - start_time) < scroll_time_limit:
    # 滚动页面
    driver.execute_script("window.scrollBy(0, 4000);")  # 适当调整滚动的像素值
    time.sleep(2)  # 等待页面加载
    

# 初始化一個空列表來儲存所有公司的資料
companies_info = []

# 找到每個公司區塊的元素
infoTags = driver.find_elements(By.CLASS_NAME, 'job_item_detail.corp_item.d-flex.body_4')

for infoTag in infoTags:
    # 提取該區塊中所有文本
    elements_text = infoTag.text.split('\n')
    
    data = ['', '', '', '']
    
    # 根據規則分類文本
    for text in elements_text:
        if "區" in text:
            data[0] = text  # 第一個位置存儲區域資訊
        elif "元" in text:
            data[2] = text  # 第三個位置存儲資本額
        elif "員工" in text:
            data[3] = text  # 第四個位置存儲員工人數
        else:
            data[1] = text  # 第二個位置存儲產業類別
    
    # 將整理後的資訊加入到公司資訊列表中
    companies_info.append(data)

df = pd.DataFrame(companies_info, columns=['地區', '產業', '資本額', '員工人數'])

# 將DataFrame保存為Excel文件
excel_path = 'companies_info.xlsx'
df.to_excel(excel_path, index=False)



# 關閉瀏覽器
driver.close()
    
    
    