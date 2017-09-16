Init = (function() {

  var components = {};

  return {
    registerComponent: function(uri, handler, opts) {
      if (components.hasOwnProperty(uri)) {
        throw '"'+ uri +'" is already defined.';
      }

      opts = opts || {};
      components[uri] = {
        h: handler,
        p: opts.priority || 0
      };
    },

    run: function(scope) {
      var elements = (scope || document).querySelectorAll('[data-component]');
      var queue = [];
      var i;

      for (i = 0; i < elements.length; i += 1) {
        var el = elements[i];
        var handler = components[el.getAttribute('data-component')];

        // Only queue uninitialized elements with a registered handler:
        if (handler && !el.__init) {
          el.__init = true;
          queue.push({ el: el, h: handler.h,  p: handler.p });
        }
      }

      // Sort elements by setup priority:
      queue = queue.sort(function(a, b) { return a.p - b.p });

      for (i = 0; i < queue.length; i += 1) {
        var component = queue[i];
        if (Backbone.View.prototype.isPrototypeOf(component.h.prototype)) {
          new component.h({ el: component.el });
        } else {
          component.h(component.el);
        }
      }
    }
  };

})();