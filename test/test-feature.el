(describe "hci"
  (describe "package installation"
    (it "use package is installed"
      (expect (fboundp 'use-packag) :to-be-truthy))))
