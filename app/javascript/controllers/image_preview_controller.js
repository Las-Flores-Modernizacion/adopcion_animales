import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "previewContainer"]

  connect() {
    this.dt = new DataTransfer()
  }

  preview(event) {
    const input = event.target

    for (let file of input.files) {
      this.dt.items.add(file)
    }

    this.syncInputs()
    this.renderPreviews()
  }

  remove(event) {
    event.preventDefault()

    const indexToRemove = parseInt(event.currentTarget.dataset.index)
    const newDt = new DataTransfer()

    Array.from(this.dt.files).forEach((file, index) => {
      if (index !== indexToRemove) {
        newDt.items.add(file)
      }
    })

    this.dt = newDt
    this.syncInputs()
    this.renderPreviews()
  }

  syncInputs() {
    this.inputTargets.forEach((input, index) => {
      if (index === 0) {
        input.files = this.dt.files
        input.name = "report[photo][]"
      } else {
        input.name = ""
      }
    })
  }

  renderPreviews() {
    this.previewContainerTarget.innerHTML = ""

    if (this.dt.files.length > 0) {
      this.previewContainerTarget.classList.remove("hidden")

      Array.from(this.dt.files).forEach((file, index) => {
        if (!file.type.startsWith("image/")) return

        const reader = new FileReader()
        reader.onload = (e) => {
          const imgHTML = `
            <div class="relative group aspect-square">
              <img src="${e.target.result}" class="w-full h-full object-cover rounded-xl border border-neutral-200 dark:border-neutral-700 shadow-sm" alt="Previsualización" />

              <button type="button"
                      data-action="click->image-preview#remove"
                      data-index="${index}"
                      class="absolute top-2 right-2 bg-neutral-900/70 hover:bg-red-600 text-white rounded-full p-1.5 backdrop-blur-sm transition-colors shadow-sm"
                      title="Quitar imagen">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </button>
            </div>
          `
          this.previewContainerTarget.insertAdjacentHTML('beforeend', imgHTML)
        }
        reader.readAsDataURL(file)
      })
    } else {
      this.previewContainerTarget.classList.add("hidden")
    }
  }
}
