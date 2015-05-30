runtime! plugin/pangu.vim

describe 'pangu#spacing'
  it 'removes non-begin-of-line redundant continuous spaces'
    Expect pangu#spacing('foo    bar')   == 'foo bar'
    Expect pangu#spacing("  foo\n  bar") == "  foo\n  bar"
  end

  describe 'convert half-width punctuations after CJK char to full-width'
    it 'recognizes specific punctuations'
      Expect pangu#spacing('一.二,三;四!五:六?七\八') == '一。二，三；四！五：六？七、八'
    end

    it 'removes a training space which is for non-CJK word stop'
      Expect pangu#spacing("情谷底,我在絕. love abyss,I'm.") == "情谷底，我在絕。love abyss,I'm."
      Expect pangu#spacing("我在絕.    love abyss,I'm.")     == "我在絕。   love abyss,I'm."
    end

    it "doesn't remove training spaces if no reason"
      Expect pangu#spacing("我在絕.    ") == "我在絕。    "
    end
  end

  it 'converts half-width qoutes around CJK char'
    Expect pangu#spacing('一(二)三') == '一（二）三'
    Expect pangu#spacing('四[五]六') == '四「五」六'
    Expect pangu#spacing('七<八>九') == '七〈八〉九'
  end

  it 'removes repeated CJK punctuations'
    Expect pangu#spacing('。。，，；；；')  == '；'
    Expect pangu#spacing('？？！！！！')    == '！'
    Expect pangu#spacing('《《》》》《》')  == '》'
    " Expect pangu#spacing('。。，，；；；')  == '。，；'
    " Expect pangu#spacing('？？！！！！')    == '？！'
    " Expect pangu#spacing('《《》》》《》')  == '《》《》'
  end

  it 'replaces full-width digit with half-width one'
    Expect pangu#spacing('０１２３４５６７８９') == '0123456789'
  end

  it 'replaces full-width alphabetic with half-width one'
    Expect pangu#spacing('ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ') == 'abcdefghijklmnopqrstuvwxyz'
    Expect pangu#spacing('ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ') == 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  end

  it 'replaces full-width non-cjk punctuation with half-width one'
    Expect pangu#spacing('＠') == '@'
  end

  it 'adds space between CJK / non-CJK words'
    Expect pangu#spacing('但是all何night')   == '但是 all 何 night'
  end

  it 'removes first and last spaces'
    Expect pangu#spacing(' [')   == '['
    Expect pangu#spacing('foo ') == 'foo'
  end

  it 'change arbitrary input text'
    SKIP 'not finish implemtment'
    let subject = readfile('t/fixtures/bad.txt')
    Expect pangu#spacing(subject) == readfile('t/fixtures/good.txt')
  end

  describe 'markdown files'
    it 'preserves punctuations of inline link'
      Expect pangu#spacing('前文[中文](http://example.com/ "標題")後文') == '前文[中文](http://example.com/ "標題")後文'
      Expect pangu#spacing('前文[中文](/relative/path/ "標題")後文')     == '前文[中文](/relative/path/ "標題")後文'
    end

    it 'preserves punctuations of reference link'
      Expect pangu#spacing('前文[中文][參考]後文') == '前文[中文][參考]後文'
    end
  end
end

describe ':Pangu'
  it 'change whole file content'
    edit t/fixtures/bad.txt
    Pangu
    Expect getline(1, '$') == readfile('t/fixtures/good.txt')
  end
end

describe ':PanguEnable'
end

describe ':PanguDisable'
end
