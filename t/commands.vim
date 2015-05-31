runtime! plugin/pangu.vim

describe ':Pangu'
  before
    language ctype zh_TW.utf8
  end

  it '處理整個檔案內容'
    edit t/fixtures/bad.txt
    Pangu
    Expect getline(1, '$') == readfile('t/fixtures/good.txt')
  end
end

describe ':PanguEnable'
end

describe ':PanguDisable'
end
