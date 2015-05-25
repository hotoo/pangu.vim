runtime! plugin/pangu.vim

describe 'pangu#spacing'
  it 'removes non-begin-of-line redundant continuous spaces'
    Expect pangu#spacing('foo  bar') == 'foobar'
  end

  it 'convert half-width punctuation after CJK char'
    Expect pangu#spacing('一.二,三;四!五:六?七\八') == '一。二，三；四！五：六？七、八'
  end

  it 'change arbitrary input text'
    SKIP 'not finish implemtment'
    let subject = readfile('t/fixtures/bad.txt')
    Expect pangu#spacing(subject) == readfile('t/fixtures/good.txt')
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
