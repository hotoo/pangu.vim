runtime! plugin/pangu.vim

describe 'pangu#spacing'
  it 'change arbitrary input text'
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
