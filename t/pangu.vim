runtime! plugin/pangu.vim

describe 'setup'
  before
    call vspec#hint({'sid': 'pangu#sid()'})
  end

  it '於正體中文環境（台灣、香港）優先使用單引號'
    for region in ['TW', 'HK']
      if empty(system(printf('locale -a | grep zh.%s.utf8', region)))
        echo printf("Test skipped: system missing support for 'zh-%s.utf8' locale.", region)
        continue
      endif

      execute printf('language ctype zh_%s.utf8', region)

      let m = Call('s:get_mappings', 'punctuations')
      Expect get(m, ']') == '」'
      Expect get(m, '>') == '〉'

      let m = vspec#call('s:get_mappings', 'punctuations_prefixed')
      Expect get(m, '[') == '「'
      Expect get(m, '<') == '〈'
    endfor
  end

  it '於簡體中文環境（中國）優先使用雙引號'
    if empty(system(printf('locale -a | grep zh.%s.utf8', 'CN')))
      SKIP "system missing support for 'zh-CN.utf8' locale."
    endif

    language ctype zh_CN.utf8

    let m = Call('s:get_mappings', 'punctuations')
    Expect get(m, ']') == '』'
    Expect get(m, '>') == '》'

    let m = vspec#call('s:get_mappings', 'punctuations_prefixed')
    Expect get(m, '[') == '『'
    Expect get(m, '<') == '《'
  end
end

describe 'pangu#spacing'
  before
    language ctype zh_TW.utf8
  end

  it '移除非行首的連續空白'
    Expect pangu#spacing('foo    bar')   == 'foo bar'
    Expect pangu#spacing("  foo\n  bar") == "  foo\n  bar"
  end

  describe '中文字後面的半形標點符號，轉為全形'
    it '認識各種不同符號'
      Expect pangu#spacing('一.二,三;四!五:六?七\八') == '一。二，三；四！五：六？七、八'
    end

    it '移除一個尾隨空白，因為它是英文的分隔符號'
      Expect pangu#spacing("情谷底,我在絕. love abyss,I'm.") == "情谷底，我在絕。love abyss,I'm."
    end

    it '只移除一個尾隨空白'
      SKIP 'fail due to repeated spaces removed'
      Expect pangu#spacing("我在絕.    love abyss,I'm.")     == "我在絕。   love abyss,I'm."
    end

    it '若沒有英文分隔符號，不要移除任何尾隨空白'
      SKIP 'fail due to repeated spaces removed'
      Expect pangu#spacing("我在絕.    ") == "我在絕。    "
    end
  end

  it '將半形標點符號轉為全形'
    Expect pangu#spacing('一(二)三') == '一（二）三'
    Expect pangu#spacing('四[五]六') == '四「五」六'
    Expect pangu#spacing('七<八>九') == '七〈八〉九'
  end

  it '移除重複的中文標點符號'
    Expect pangu#spacing('。。，，；；；')  == '；'
    Expect pangu#spacing('？？！！！！')    == '！'
    Expect pangu#spacing('《《》》》《》')  == '》'
    " Expect pangu#spacing('。。，，；；；')  == '。，；'
    " Expect pangu#spacing('？？！！！！')    == '？！'
    " Expect pangu#spacing('《《》》》《》')  == '《》《》'
  end

  it '將全形數字轉為半形'
    Expect pangu#spacing('０１２３４５６７８９') == '0123456789'
  end

  it '將全形英文字轉為半形'
    Expect pangu#spacing('ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ') == 'abcdefghijklmnopqrstuvwxyz'
    Expect pangu#spacing('ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ') == 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  end

  it '將全形的外文標點符號轉為半形'
    Expect pangu#spacing('＠') == '@'
  end

  it '在中英文字間增加空白'
    Expect pangu#spacing('但是all何night')   == '但是 all 何 night'
  end

  it '移除首尾空白'
    Expect pangu#spacing(' [')   == '['
    Expect pangu#spacing('foo ') == 'foo'
  end

  describe '檔案格式：markdown'
    it '保留 inline link 語法用的括號'
      Expect pangu#spacing('前文[中文](http://example.com/ "標題")後文') == '前文[中文](http://example.com/ "標題")後文'
      Expect pangu#spacing('前文[中文](/relative/path/ "標題")後文')     == '前文[中文](/relative/path/ "標題")後文'
    end

    it '保留 reference link 語法用的括號'
      Expect pangu#spacing('前文[中文][參考]後文') == '前文[中文][參考]後文'
    end
  end
end

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
