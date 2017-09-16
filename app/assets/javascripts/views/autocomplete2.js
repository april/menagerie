// var AutocompleteMenuView = Backbone.View.extend({
//   menuFocus: false,
//   selection: 0,
//   input: null,

//   initialize: function() {
//     this.options = window[this.$el.data('src')];

//     this.$menu = $('<ul class="autocomplete-menu"></ul>')
//       .on('mouseover', 'li', this.onMenuOver.bind(this))
//       .on('mousedown', 'li', this.onMenuDown.bind(this))
//       .on('click', 'li', this.onMenuClick.bind(this));

//     this.el.setAttribute('autocomplete', 'off');
//     this.$el.closest('form').on('submit', function() {
//       this.el.removeAttribute('autocomplete');
//     }.bind(this));
//   },

//   setMenu: function(opts) {
//     if (opts && opts.length) {
//       this.$menu.html(opts.map(function(opt, index) { return '<li data-index="'+ index +'" data-value="'+ opt +'" class="'+ (index === 0 ? 'active' : '') +'">' + opt + '</li>'; }).join(''));
//       this.$el.parent().append(this.$menu);
//     } else {
//       this.$menu.detach().html('');
//     }
//   },

//   isMenuOpen: function() {
//     return !!this.$menu.parent().length;
//   },

//   browseMenu: function(dir) {
//     var $items = this.$menu.children('li');
//     this.selection = Math.max(0, Math.min(this.selection + dir, $items.length - 1));

//     var $active = $items
//       .removeClass('active')
//       .eq(this.selection)
//       .addClass('active');
//   },

//   autoComplete: function() {
//     var term = this.$menu.children('li').eq(this.selection).data('value');
//     this.el.value = term;
//     this.el.focus();
//     this.setMenu(null);
//   },

//   events: {
//     'input': 'onChange',
//     'keydown': 'onKeydown',
//     'focus .js-autocomplete-field': 'onFocus',
//     'blur .js-autocomplete-field': 'onBlur',
//   },

//   onChange: function() {
//     var term = this.el.value;

//     if (term.length >= 1) {
//       var options = this.options.filter(function(opt) { return term === opt.slice(0, term.length) });
//       this.setMenu(options.slice(0, 5));
//     } else {
//       this.setMenu(null);
//     }
//   },

//   onKeydown: function(evt) {
//     if (this.isMenuOpen()) {
//       var UP_KEY = 38;
//       var DOWN_KEY = 40;
//       var ENTER_KEY = 13;

//       if (evt.which === DOWN_KEY) {
//         this.browseMenu(1);
//       } else if (evt.which === UP_KEY) {
//         this.browseMenu(-1);
//       } else if (evt.which === ENTER_KEY) {
//         this.autoComplete();
//       }

//       if ([UP_KEY, DOWN_KEY, ENTER_KEY].indexOf(evt.which) >= 0) {
//         evt.preventDefault();
//       }
//     }
//   },

//   onFocus: function(evt) {
//     this.input = evt.currentTarget;
//   },

//   onBlur: function(evt) {
//     if (this.isMenuOpen() && !this.menuFocus) {
//       this.setMenu(null);
//     }
//     this.input = null;
//   },

//   onMenuOver: function(evt) {
//     var $active = this.$menu
//       .children('li')
//       .removeClass('active')
//       .filter(evt.currentTarget)
//       .addClass('active');

//     this.selection = $active.data('index');
//   },

//   onMenuDown: function() {
//     this.menuFocus = true;
//   },

//   onMenuClick: function(evt) {
//     this.menuFocus = false;
//     this.selection = $(evt.currentTarget).data('index');
//     this.autoComplete();
//   }
// });

// Init.registerComponent('autocomplete-menu', AutocompleteMenuView);