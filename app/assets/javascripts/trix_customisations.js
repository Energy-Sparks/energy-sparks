// modify Trix config before its initialised so it doesn't strip the heading tags
addEventListener("trix-before-initialize", event => {
  addHeadingAttributes()
})

// extend trix config so it knows what to do with heading elements
function addHeadingAttributes() {
  Array.from(["h1", "h2", "h3", "h4", "h5", "h6"]).forEach((tagName, i) => {
    Trix.config.blockAttributes[`heading${(i + 1)}`] = { tagName: tagName, terminal: true, breakOnReturn: true, group: false }
  })
}

addEventListener("trix-initialize", event => {
  const customiser = new TrixCustomiser(event.target)
  customiser.addUrlValidation()

  var components = $(event.target).parents('.forms-trix-component');
  if (components.length) {
    var component = components[0]

    if (component.classList.contains('controls-simple')) {
      customiser.createSimplifiedEditor()
    } else if (component.classList.contains('controls-advanced')) {
      customiser.createAdvancedEditor()
    }

    if (component.dataset.chartList) {
      customiser.addChartButton(JSON.parse(component.dataset.chartList))
    }
  }
})

function findYoutubeId(str) {
  try {
    const url = new URL(str);
    return url.searchParams.has('v') ? url.searchParams.get('v') : url.pathname.split('/').pop()
  } catch (e) {
    return null;
  }
}

document.addEventListener('trix-action-invoke', function(event) {
  const target = event.target
  if(event.actionName === 'x-insert-chart') {
    target.editor.insertHTML("{{#chart}}" + $('select[name="chart-list-chart"]').val() + "{{/chart}}")
  }
  if(event.actionName === 'x-insert-youtube') {
    const dialog = event.invokingElement.closest('.trix-dialog--youtube')
    const input = dialog.querySelector('input[name="youtube-url"]')
    const youtube_id = findYoutubeId(input.value)
    if (youtube_id !== null) {
      fetch(`/cms/youtube_embed/${encodeURIComponent(youtube_id)}`)
        .then(response => {
          if (!response.ok) throw new Error(response.statusText)
          return response.json()
        })
       .then(embed => {
          const attachment = new Trix.Attachment(embed)
          target.editor.insertAttachment(attachment)
          target.editorController.toolbarController.hideDialog()
        })
        .catch(error => {
          console.log(error.message)
        })

    }
  }
})

class TrixCustomiser {
  constructor(element) {
    this.element = element
  }

  addUrlValidation() {
    const inputElement = this.toolbarElement.querySelector("input[name=href]")
    inputElement.type = "text"
    inputElement.pattern = "(https?://|/|\.\./|mailto:).+"
  }

  createSimplifiedEditor() {
    this.buttonGroupBlockTools.removeChild(this.getButton('quote'))
    this.buttonGroupBlockTools.removeChild(this.getButton('code'))
  }

  createAdvancedEditor() {
    this.replaceHeadingButton();
    this.addYoutubeButton();
  }

  addChartButton(chart_list) {
    this.buttonGroupTextTools.insertAdjacentHTML("beforeend", this.chartButtonTemplate)
    this.dialogsElement.insertAdjacentHTML("beforeend", this.chartDialogTemplate(chart_list))
  }

  replaceHeadingButton() {
    // remove existing button
    this.buttonGroupBlockTools.removeChild(this.getButton('heading1'))
    // add in new replacement
    this.buttonGroupBlockTools.insertAdjacentHTML("afterbegin", this.headingButtonTemplate)
    // add in dialog for new H1-H6 selection
    this.dialogsElement.insertAdjacentHTML("beforeend", this.headingDialogTemplate)
  }

  addYoutubeButton() {
    this.buttonGroupFileTools.insertAdjacentHTML("beforeend", this.youtubeButtonTemplate)
    this.dialogsElement.insertAdjacentHTML("beforeend", this.youtubeDialogTemplate)
  }

  getButton(selector) {
    return this.toolbarElement.querySelector(`[data-trix-attribute=${selector}]`)
  }

  get headingButtonTemplate() {
    return '<button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-action="x-heading" title="Heading" tabindex="-1">Heading</button>'
  }

  get headingDialogTemplate() {
    return `
      <div class="trix-dialog trix-dialog--heading" data-trix-dialog="x-heading" data-trix-dialog-attribute="x-heading">
        <div class="trix-dialog__link-fields">
          <input type="text" name="x-heading" class="trix-dialog-hidden__input" data-trix-input>
          <div class="trix-button-group">
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading1">H1</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading2">H2</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading3">H3</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading4">H4</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading5">H5</button>
            <button type="button" class="trix-button trix-button--dialog" data-trix-attribute="heading6">H6</button>
          </div>
        </div>
      </div>
    `
  }

  get chartButtonTemplate() {
    return '<button type="button" class="trix-button" data-trix-action="chart" data-trix-key="c" title="Chart" tabindex="-1" data-trix-active=""><i class="fas fa-chart-bar"></i></button>'
  }

  chartDialogTemplate(chart_list) {
    var options = chart_list.map(group => {
      var name = group[0]
      var charts = group[1]
      var chart_options = charts.map(c => `<option value="${c}">${c}</option>`).join("")
      return `<optgroup label="${name}">${chart_options}</optgroup>`
    }).join("");

    return `
      <div class="trix-dialog trix-dialog--chart" data-trix-dialog="chart">
        <div class="trix-dialog__link-fields">
          <select name="chart-list-chart" class="mr-3">
          ${options}
          </select>
          <div class="trix-button-group">
            <input type="button"
                   class="trix-button trix-button--dialog"
                   value="Insert"
                   data-trix-action="x-insert-chart">
          </div>
        </div>
      </div>
    `
  }

  get youtubeButtonTemplate() {
    return '<button type="button" class="trix-button" data-trix-action="youtube" data-trix-key="y" title="Youtube" tabindex="-1" data-trix-active=""><i class="fa-brands fa-youtube"></i></button>'
  }

  get youtubeDialogTemplate() {
    return `
      <div class="trix-dialog trix-dialog--youtube" data-trix-dialog="youtube">
        <div class="trix-dialog__link-fields">
          <input type="text" name="youtube-url" placeholder="Enter Youtube URL..." class="trix-input trix-input--dialog mr-3">
          <div class="trix-button-group">
            <input type="button"
                   class="trix-button trix-button--dialog"
                   value="Insert"
                   data-trix-action="x-insert-youtube">
          </div>
        </div>
      </div>
    `
  }

  get dialogsElement() {
    return this.toolbarElement.querySelector("[data-trix-dialogs]")
  }

  get buttonGroupFileTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=file-tools]")
  }

  get buttonGroupTextTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=text-tools]")
  }

  get buttonGroupBlockTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=block-tools]")
  }

  get toolbarElement() {
    return this.element.toolbarElement
  }
}
