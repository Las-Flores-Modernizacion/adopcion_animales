import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.scrollToBottom()

    this.observer = new MutationObserver((mutations) => {
      let shouldScroll = false
      for (const mutation of mutations) {
        if (mutation.addedNodes.length > 0) {
          shouldScroll = true
          break
        }
      }

      if (shouldScroll) {
        setTimeout(() => {
          this.scrollToBottom()
        }, 100)
      }
    })

    this.observer.observe(this.element, {
      childList: true,
      subtree: true
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  scrollToBottom() {
    const lastElementChild = this.element.lastElementChild
    if (lastElementChild) {
      lastElementChild.scrollIntoView({ behavior: 'smooth', block: 'end' })
    } else {
      this.element.scrollTo({
        top: this.element.scrollHeight,
        behavior: 'smooth'
      })
    }
  }
}
