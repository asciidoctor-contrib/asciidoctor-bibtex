# Test cases for formatting references
#
# Copyright (c) Peter Lane, 2012.
# Copyright (c) Zhang Yang, 2019.
# Released under Open Works License, 0.9.2

require 'minitest/autorun'
require_relative '../lib/asciidoctor-bibtex/processor'

include AsciidoctorBibtex

describe AsciidoctorBibtex do
  it "must return Chicago style references" do
    p = Processor.new 'test/data/test.bib', false, 'chicago-author-date'
    _(p.build_bibliography_item('smith10')).must_equal "Smith, D. 2010. _Book Title_. Mahwah, NJ: Lawrence Erlbaum."
    _(p.build_bibliography_item('brown09')).must_equal "Brown, J., ed. 2009. _Book Title_. OUP."
  end

  it "must return numeric style (IEEE) references" do
    p = Processor.new 'test/data/test.bib', false, 'ieee'
    _(p.build_bibliography_item('smith10', 0)).must_equal "[1] D. Smith, _Book title_. Mahwah, NJ: Lawrence Erlbaum, 2010."
    _(p.build_bibliography_item('brown09', 1)).must_equal "[2] J. Brown, Ed., _Book title_. OUP, 2009."
  end

  it "must support custom template in numeric style (IEEE) references" do
    p = Processor.new 'test/data/test.bib', false, 'ieee', custom_citation_template: '/$id/'
    _(p.build_bibliography_item('smith10', 0)).must_equal "/1/ D. Smith, _Book title_. Mahwah, NJ: Lawrence Erlbaum, 2010."
    _(p.build_bibliography_item('brown09', 1)).must_equal "/2/ J. Brown, Ed., _Book title_. OUP, 2009."
  end

  it "must return harvard style (APA) references" do
    p = Processor.new 'test/data/test.bib', false, 'apa'
    _(p.build_bibliography_item('smith10')).must_equal "Smith, D. (2010). _Book title_. Lawrence Erlbaum."
    _(p.build_bibliography_item('brown09')).must_equal "Brown, J. (Ed.). (2009). _Book title_. OUP."
  end

  it "must sort citations correctly" do
    begin
      p = Processor.new 'test/data/sort.bib', true, 'ieee'
      p.process_citation_macros 'cite:[Morgan2018, Morgan2006]'
      p.finalize_macro_processing
    rescue
      fail 'Should not throw exception when sorting citations'
    end
  end

  it "must handle multiple bibliographies" do
    p = Processor.new ['test/data/test.bib', 'test/data/test-multiple.bib'], false, 'ieee'
    _(p.build_bibliography_item('brown10', 0)).must_equal "[1] J. B. Jr, Ed., _Other book title_. OUP, 2010."
    _(p.build_bibliography_item('smith10', 1)).must_equal "[2] D. Smith, _Book title_. Mahwah, NJ: Lawrence Erlbaum, 2010."
    _(p.build_bibliography_item('brown09', 2)).must_equal "[3] J. Brown, Ed., _Book title_. OUP, 2009."
  end

end

