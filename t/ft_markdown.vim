describe '檔案格式：markdown'
  it '保留 inline link 語法用的括號'
    Expect pangu#spacing('前文[中文](http://example.com/ "標題")後文') == '前文[中文](http://example.com/ "標題")後文'
    Expect pangu#spacing('前文[中文](/relative/path/ "標題")後文')     == '前文[中文](/relative/path/ "標題")後文'
  end

  it '保留 reference link 語法用的括號'
    Expect pangu#spacing('前文[中文][參考]後文') == '前文[中文][參考]後文'
  end
end
