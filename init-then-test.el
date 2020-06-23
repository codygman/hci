(message (format "we are in %s" (pwd)))
(load (format "%s/init.el" (getenv "TRAVIS_BUILD_DIR")))
(message (format "now we are in %s" (pwd)))
(buttercup-run-discover)
