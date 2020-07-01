(describe "A suite"
  (it "contains a spec with an expectation"
      (expect t :to-be t))
  (it "emacs version should be 28.0.50"
      (expect emacs-version :to-be "28.0.50")))
