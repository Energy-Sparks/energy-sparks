addEventListener("trix-initialize", function(event) {
  var parentWrapper = $(event.target).parents('.chart-list');

  if(parentWrapper.length){
    var buttonHTML = $('#trix-chart-list-components button[data-trix-action="chart"]')[0];
    var dialogHTML = $('#trix-chart-list-components .trix-dialog')[0];

    $(event.target.toolbarElement).find('.trix-button-group--text-tools').append(buttonHTML);
    $(event.target.toolbarElement).find('.trix-dialogs').append(dialogHTML);
  }
});

document.addEventListener("trix-action-invoke", function(event) {
  if(event.actionName === "x-insert-chart"){
    var element = event.target;
    var parentWrapper = $(element).parents('.chart-list');
    element.editor.insertHTML("{{#chart}}" + $('select[name="chart-list-chart"]').val() + "{{/chart}}");
  }
})

addEventListener("trix-initialize", event => {
  const { toolbarElement } = event.target
  const inputElement = toolbarElement.querySelector("input[name=href]")
  inputElement.type = "text"
  inputElement.pattern = "(https?://|/|\.\./|mailto:).+"
})

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
  console.log('CUSTOMISE')
  var customiser = new TrixCustomiser(event.target)
  if ($(event.target).parents('.controls-simple').length) {
    customiser.createSimplifiedEditor()
  } else if ($(event.target).parents('.controls-advanced').length) {
    customiser.createAdvancedEditor()
  }
  console.log('DONE')
})

class TrixCustomiser {
  constructor(element) {
    console.log(element.toolbarElement)
    this.element = element
  }

  createSimplifiedEditor() {
    this.buttonGroupBlockTools.removeChild(this.getButton('quote'))
    this.buttonGroupBlockTools.removeChild(this.getButton('code'))
  }

  createAdvancedEditor() {
    this.replaceHeadingButton();
  }

  replaceHeadingButton() {
    // remove existing button
    this.buttonGroupBlockTools.removeChild(this.getButton('heading1'))
    // add in new replacement
    this.buttonGroupBlockTools.insertAdjacentHTML("afterbegin", this.headingButtonTemplate)
    // add in dialog for new H1-H6 selection
    this.dialogsElement.insertAdjacentHTML("beforeend", this.dialogHeadingTemplate)
  }

  getButton(selector) {
    return this.toolbarElement.querySelector(`[data-trix-attribute=${selector}]`)
  }

  get headingButtonTemplate() {
    return '<button type="button" class="trix-button trix-button--icon trix-button--icon-heading-1" data-trix-action="x-heading" title="Heading" tabindex="-1">Heading</button>'
  }

  get dialogHeadingTemplate() {
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

  get dialogsElement() {
    return this.toolbarElement.querySelector("[data-trix-dialogs]")
  }

  get buttonGroupBlockTools() {
    return this.toolbarElement.querySelector("[data-trix-button-group=block-tools]")
  }

  get toolbarElement() {
    return this.element.toolbarElement
  }
}
