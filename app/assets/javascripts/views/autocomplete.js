var AutocompleteFormView = Backbone.View.extend({
  menuFocus: false,
  selection: 0,
  input: null,

  initialize: function() {
    this.$menu = $('<ul class="autocomplete-menu"></ul>')
      .on('mouseover', 'li', this.onMenuOver.bind(this))
      .on('mousedown', 'li', this.onMenuDown.bind(this))
      .on('click', 'li', this.onMenuClick.bind(this));

    // this.el.setAttribute('autocomplete', 'off');
    // this.$el.closest('form').on('submit', function() {
    //   this.el.removeAttribute('autocomplete');
    // }.bind(this));
  },

  setMenu: function(opts) {
    if (!this.input) return;
    if (opts && opts.length) {
      this.selection = 0;
      this.$menu.html(opts.map(function(opt, index) { return '<li data-index="'+ index +'" data-value="'+ opt +'" class="'+ (index === 0 ? 'active' : '') +'">' + opt + '</li>'; }).join(''));
      this.$(this.input).parent().append(this.$menu);
    } else {
      this.$menu.detach().html('');
    }
  },

  isMenuOpen: function() {
    return !!this.$menu.parent().length;
  },

  browseMenu: function(dir) {
    if (this.locked()) return;
    var $items = this.$menu.children('li');
    this.selection = Math.max(0, Math.min(this.selection + dir, $items.length - 1));

    var $active = $items
      .removeClass('active')
      .eq(this.selection)
      .addClass('active');
  },

  autoComplete: function() {
    if (this.locked()) return;
    var term = this.$menu.children('li').eq(this.selection).data('value');
    this.input.value = term;
    this.input.focus();
    this.setMenu(null);
  },

  events: {
    'input': 'onChange',
    'keydown': 'onKeydown',
    'focus input[data-src]': 'onFocus',
    'blur input[data-src]': 'onBlur',
  },

  onFocus: function(evt) {
    this.input = evt.currentTarget;
    this.options = window[this.$(this.input).data('src')];
  },

  onBlur: function(evt) {
    if (this.isMenuOpen() && !this.menuFocus) {
      //this.setMenu(null);
    }
  },

  onChange: function() {
    if (!this.input) return;
    var term = this.input.value;

    if (term.length >= 2) {
      var options = this.options.filter(function(opt) { return term.toLowerCase() === opt.slice(0, term.length).toLowerCase() });
      this.setMenu(options.slice(0, 5));
    } else {
      this.setMenu(null);
    }
  },

  onKeydown: function(evt) {
    if (this.locked()) return;
    if (this.isMenuOpen()) {
      var UP_KEY = 38;
      var DOWN_KEY = 40;
      var ENTER_KEY = 13;
      var TAB_KEY = 9;

      if (evt.which === DOWN_KEY) {
        this.browseMenu(1);
      } else if (evt.which === UP_KEY) {
        this.browseMenu(-1);
      } else if (evt.which === ENTER_KEY) {
        this.autoComplete();
      } else if (evt.which === TAB_KEY) {
        this.setMenu(null);
      }

      if ([UP_KEY, DOWN_KEY, ENTER_KEY].indexOf(evt.which) >= 0) {
        evt.preventDefault();
      }
    }
  },

  onMenuOver: function(evt) {
    if (this.locked()) return;
    var $active = this.$menu
      .children('li')
      .removeClass('active')
      .filter(evt.currentTarget)
      .addClass('active');

    this.selection = $active.data('index');
  },

  onMenuDown: function() {
    if (this.locked()) return;
    this.menuFocus = true;
  },

  onMenuClick: function(evt) {
    if (this.locked()) return;
    this.menuFocus = false;
    this.selection = $(evt.currentTarget).data('index');
    this.autoComplete();
  },

  locked: function() {
    return !this.input || !this.options;
  }
});

Init.registerComponent('autocomplete-form', AutocompleteFormView);