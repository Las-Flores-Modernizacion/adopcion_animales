# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "compressorjs" # @1.3.0
pin "embla-carousel", to: "https://cdn.jsdelivr.net/npm/embla-carousel/embla-carousel.esm.js"
pin "embla-carousel-wheel-gestures", to: "https://cdn.jsdelivr.net/npm/embla-carousel-wheel-gestures@latest/+esm"
pin "@floating-ui/dom", to: "https://cdn.jsdelivr.net/npm/@floating-ui/dom@1.7.6/+esm"
pin "tom-select", to: "https://cdn.jsdelivr.net/npm/tom-select@2.6.1/+esm"

