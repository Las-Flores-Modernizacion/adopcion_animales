import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-to-bottom"
export default class extends Controller {
  connect() {
    this.scrollToBottom()
    
    this.observer = new MutationObserver(() => {
      this.scrollToBottom()
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
    this.element.scrollTo({
      top: this.element.scrollHeight,
      behavior: 'smooth'
    })
  }
}
