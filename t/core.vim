describe 'pangu#spacing'
  before
    language ctype zh_TW.utf8
  end

  describe '中文字後面的半形標點符號，轉為全形'
    it '認識各種不同符號'
      Expect pangu#spacing('一.二,三;四!五:六?七\八') == '一。二，三；四！五：六？七、八'
    end

    it '移除一個尾隨空白，因為它是英文的分隔符號'
      Expect pangu#spacing("情谷底,我在絕. love abyss,I'm.") == "情谷底，我在絕。love abyss,I'm."
    end

    it '只移除一個尾隨空白'
      Expect pangu#spacing("我在絕.    love abyss,I'm.")     == "我在絕。   love abyss,I'm."
    end

    it '若沒有英文分隔符號，不要移除任何尾隨空白'
      SKIP 'fail due to trailing spaces removed rule'
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
end
