/*!
 * wavesurfer.js 2.1.0 (Mon Oct 01 2018 11:34:54 GMT+0200 (Central European Summer Time))
 * https://github.com/katspaugh/wavesurfer.js
 * @license BSD-3-Clause
 */
! function(e, t) {
  "object" == typeof exports && "object" == typeof module ? module.exports = t() : "function" == typeof define && define.amd ? define("regions", [], t) : "object" == typeof exports ? exports.regions = t() : (e.WaveSurfer = e.WaveSurfer || {}, e.WaveSurfer.regions = t())
}(window, function() {
  return function(r) {
    var n = {};

    function i(e) {
      if (n[e]) return n[e].exports;
      var t = n[e] = {
        i: e,
        l: !1,
        exports: {}
      };
      return r[e].call(t.exports, t, t.exports, i), t.l = !0, t.exports
    }
    return i.m = r, i.c = n, i.d = function(e, t, r) {
      i.o(e, t) || Object.defineProperty(e, t, {
        enumerable: !0,
        get: r
      })
    }, i.r = function(e) {
      "undefined" != typeof Symbol && Symbol.toStringTag && Object.defineProperty(e, Symbol.toStringTag, {
        value: "Module"
      }), Object.defineProperty(e, "__esModule", {
        value: !0
      })
    }, i.t = function(t, e) {
      if (1 & e && (t = i(t)), 8 & e) return t;
      if (4 & e && "object" == typeof t && t && t.__esModule) return t;
      var r = Object.create(null);
      if (i.r(r), Object.defineProperty(r, "default", {
        enumerable: !0,
        value: t
      }), 2 & e && "string" != typeof t)
        for (var n in t) i.d(r, n, function(e) {
          return t[e]
        }.bind(null, n));
      return r
    }, i.n = function(e) {
      var t = e && e.__esModule ? function() {
        return e.default
      } : function() {
        return e
      };
      return i.d(t, "a", t), t
    }, i.o = function(e, t) {
      return Object.prototype.hasOwnProperty.call(e, t)
    }, i.p = "localhost:8080/dist/plugin/", i(i.s = 2)
  }({
    2: function(e, t, r) {
      "use strict";

      function i(e, t) {
        if (!(e instanceof t)) throw new TypeError("Cannot call a class as a function")
      }

      function n(e, t) {
        for (var r = 0; r < t.length; r++) {
          var n = t[r];
          n.enumerable = n.enumerable || !1, n.configurable = !0, "value" in n && (n.writable = !0), Object.defineProperty(e, n.key, n)
        }
      }

      function s(e, t, r) {
        return t && n(e.prototype, t), r && n(e, r), e
      }
      Object.defineProperty(t, "__esModule", {
        value: !0
      }), t.default = void 0;
      var a = function() {
          function n(e, t) {
            var r = this;
            i(this, n), this.wavesurfer = t, this.wrapper = t.drawer.wrapper, this.util = t.util, this.style = this.util.style, this.title = null == e.title ? '' : e.title, this.id = null == e.id ? t.util.getId() : e.id, this.start = Number(e.start) || 0, this.end = null == e.end ? this.start + 4 / this.wrapper.scrollWidth * this.wavesurfer.getDuration() : Number(e.end), this.resize = void 0 === e.resize || Boolean(e.resize), this.drag = void 0 === e.drag || Boolean(e.drag), this.loop = Boolean(e.loop), this.color = e.color || "rgba(0, 0, 0, 0.1)", this.data = e.data || {}, this.attributes = e.attributes || {}, this.maxLength = e.maxLength, this.minLength = e.minLength, this._onRedraw = function() {
              return r.updateRender()
            }, this.scroll = !1 !== e.scroll && t.params.scrollParent, this.scrollSpeed = e.scrollSpeed || 1, this.scrollThreshold = e.scrollThreshold || 10, this.bindInOut(), this.render(), this.wavesurfer.on("zoom", this._onRedraw), this.wavesurfer.on("redraw", this._onRedraw), this.wavesurfer.fireEvent("region-created", this)
          }
          return s(n, [{
            key: "update",
            value: function(e) {
              null != e.start && (this.start = Number(e.start)), null != e.end && (this.end = Number(e.end)), null != e.loop && (this.loop = Boolean(e.loop)), null != e.color && (this.color = e.color), null != e.data && (this.data = e.data), null != e.resize && (this.resize = Boolean(e.resize)), null != e.drag && (this.drag = Boolean(e.drag)), null != e.maxLength && (this.maxLength = Number(e.maxLength)), null != e.minLength && (this.minLength = Number(e.minLength)), null != e.attributes && (this.attributes = e.attributes), this.updateRender(), this.fireEvent("update"), this.wavesurfer.fireEvent("region-updated", this)
            }
          }, {
            key: "remove",
            value: function() {
              this.element && (this.wrapper.removeChild(this.element), this.element = null, this.fireEvent("remove"), this.wavesurfer.un("zoom", this._onRedraw), this.wavesurfer.un("redraw", this._onRedraw), this.wavesurfer.fireEvent("region-removed", this))
            }
          }, {
            key: "play",
            value: function() {
              this.wavesurfer.play(this.start, this.end), this.fireEvent("play"), this.wavesurfer.fireEvent("region-play", this)
            }
          }, {
            key: "playLoop",
            value: function() {
              var e = this;
              this.play(), this.once("out", function() {
                return e.playLoop()
              })
            }
          }, {
            key: "render",
            value: function() {
              var e = document.createElement("region");
              for (var t in e.className = "wavesurfer-region", e.title = this.title == '' ? this.formatTime(this.start, this.end) : this.title, e.setAttribute("data-id", this.id), this.attributes) e.setAttribute("data-region-" + t, this.attributes[t]);
              this.wrapper.scrollWidth;
              if (this.style(e, {
                position: "absolute",
                //zIndex: 2,
                height: "100%",
                top: "0px"
              }), this.resize) {
                var r = e.appendChild(document.createElement("handle")),
                  n = e.appendChild(document.createElement("handle"));
                r.className = "wavesurfer-handle wavesurfer-handle-start", n.className = "wavesurfer-handle wavesurfer-handle-end";
                var i = {
                  cursor: "col-resize",
                  position: "absolute",
                  left: "0px",
                  top: "0px",
                  width: "1%",
                  maxWidth: "4px",
                  height: "100%"
                };
                this.style(r, i), this.style(n, i), this.style(n, {
                  left: "100%"
                })
              }
              this.element = this.wrapper.appendChild(e), this.updateRender(), this.bindEvents(e)
            }
          }, {
            key: "formatTime",
            value: function(e, t) {
              return (e == t ? [e] : [e, t]).map(function(e) {
                return [Math.floor(e % 3600 / 60), ("00" + Math.floor(e % 60)).slice(-2)].join(":")
              }).join("-")
            }
          }, {
            key: "getWidth",
            value: function() {
              return this.wavesurfer.drawer.width / this.wavesurfer.params.pixelRatio
            }
          }, {
            key: "updateRender",
            value: function() {
              var e = this.wavesurfer.getDuration(),
                t = this.getWidth();
              if (this.start < 0 && (this.start = 0, this.end = this.end - this.start), this.end > e && (this.end = e, this.start = e - (this.end - this.start)), null != this.minLength && (this.end = Math.max(this.start + this.minLength, this.end)), null != this.maxLength && (this.end = Math.min(this.start + this.maxLength, this.end)), null != this.element) {
                var r = Math.round(this.start / e * t),
                  n = Math.round(this.end / e * t) - r;
                for (var i in this.style(this.element, {
                  left: r + "px",
                  width: n + "px",
                  backgroundColor: this.color,
                  cursor: this.drag ? "move" : "default"
                }), this.attributes) this.element.setAttribute("data-region-" + i, this.attributes[i]);
                this.element.title = this.title == '' ? this.formatTime(this.start, this.end) : this.title
              }
            }
          }, {
            key: "bindInOut",
            value: function() {
              var t = this;
              this.firedIn = !1, this.firedOut = !1;
              var e = function(e) {
                !t.firedOut && t.firedIn && (t.start >= Math.round(100 * e) / 100 || t.end <= Math.round(100 * e) / 100) && (t.firedOut = !0, t.firedIn = !1, t.fireEvent("out"), t.wavesurfer.fireEvent("region-out", t)), !t.firedIn && t.start <= e && t.end > e && (t.firedIn = !0, t.firedOut = !1, t.fireEvent("in"), t.wavesurfer.fireEvent("region-in", t))
              };
              this.wavesurfer.backend.on("audioprocess", e), this.on("remove", function() {
                t.wavesurfer.backend.un("audioprocess", e)
              }), this.on("out", function() {
                t.loop && t.wavesurfer.play(t.start)
              })
            }
          }, {
            key: "bindEvents",
            value: function() {
              var o, u, l, d, h, c, f, v, p, m, g, w, e, t, r, y = this;
              this.element.addEventListener("mouseenter", function(e) {
                y.fireEvent("mouseenter", e), y.wavesurfer.fireEvent("region-mouseenter", y, e)
              }), this.element.addEventListener("mouseleave", function(e) {
                y.fireEvent("mouseleave", e), y.wavesurfer.fireEvent("region-mouseleave", y, e)
              }), this.element.addEventListener("click", function(e) {
                e.preventDefault(), y.fireEvent("click", e), y.wavesurfer.fireEvent("region-click", y, e)
              }), this.element.addEventListener("dblclick", function(e) {
                e.stopPropagation(), e.preventDefault(), y.fireEvent("dblclick", e), y.wavesurfer.fireEvent("region-dblclick", y, e)
              }), (this.drag || this.resize) && (v = y.wavesurfer.drawer.container, p = y.wavesurfer.getDuration(), m = y.scrollSpeed, g = y.scrollThreshold, w = !1, e = function(e) {
                e.touches && 1 < e.touches.length || (u = e.targetTouches ? e.targetTouches[0].identifier : null, e.stopPropagation(), o = y.wavesurfer.drawer.handleEvent(e, !0) * p, d = y.wrapper.scrollWidth - y.wrapper.clientWidth, f = y.wrapper.getBoundingClientRect(), h = "handle" == e.target.tagName.toLowerCase() ? e.target.classList.contains("wavesurfer-handle-start") ? "start" : "end" : !(l = !0))
              }, t = function(e) {
                e.touches && 1 < e.touches.length || ((l || h) && (c = null, h = l = !1), w && (w = !1, y.util.preventClick(), y.fireEvent("update-end", e), y.wavesurfer.fireEvent("region-update-end", y, e)))
              }, r = function(e) {
                if (!(e.touches && 1 < e.touches.length) && (!e.targetTouches || e.targetTouches[0].identifier == u) && (l || h)) {
                  var t = o,
                    r = y.wavesurfer.drawer.handleEvent(e) * p,
                    n = r - o;
                  if (o = r, y.drag && l && (w = w || !!n, y.onDrag(n)), y.resize && h && (w = w || !!n, y.onResize(n, h)), y.scroll && v.clientWidth < y.wrapper.scrollWidth) {
                    if (l) {
                      var i = y.element.getBoundingClientRect(),
                        s = i.left - f.left;
                      r < t && 0 <= s ? c = -1 : t < r && s + i.width <= f.right && (c = 1), (-1 === c && g < s || 1 === c && s + i.width < f.right - g) && (c = null)
                    } else {
                      var a = e.clientX - f.left;
                      c = a <= g ? -1 : a >= f.right - g ? 1 : null
                    }
                    c && function e(t) {
                      if (c && (l || h)) {
                        var r = y.wrapper.scrollLeft + m * c;
                        y.wrapper.scrollLeft = r = Math.min(d, Math.max(0, r));
                        var n = y.wavesurfer.drawer.handleEvent(t) * p,
                          i = n - o;
                        o = n, l ? y.onDrag(i) : y.onResize(i, h), window.requestAnimationFrame(function() {
                          e(t)
                        })
                      }
                    }(e)
                  }
                }
              }, y.element.addEventListener("mousedown", e), y.element.addEventListener("touchstart", e), y.wrapper.addEventListener("mousemove", r), y.wrapper.addEventListener("touchmove", r), document.body.addEventListener("mouseup", t), document.body.addEventListener("touchend", t), y.on("remove", function() {
                document.body.removeEventListener("mouseup", t), document.body.removeEventListener("touchend", t), y.wrapper.removeEventListener("mousemove", r), y.wrapper.removeEventListener("touchmove", r)
              }), y.wavesurfer.on("destroy", function() {
                document.body.removeEventListener("mouseup", t), document.body.removeEventListener("touchend", t)
              }))
            }
          }, {
            key: "onDrag",
            value: function(e) {
              var t = this.wavesurfer.getDuration();
              this.end + e > t || this.start + e < 0 || this.update({
                start: this.start + e,
                end: this.end + e
              })
            }
          }, {
            key: "onResize",
            value: function(e, t) {
              "start" == t ? this.update({
                start: Math.min(this.start + e, this.end),
                end: Math.max(this.start + e, this.end)
              }) : this.update({
                start: Math.min(this.end + e, this.start),
                end: Math.max(this.end + e, this.start)
              })
            }
          }]), n
        }(),
        o = function() {
          function n(e, t) {
            var r = this;
            i(this, n), this.params = e, this.wavesurfer = t, this.util = t.util, Object.getOwnPropertyNames(this.util.Observer.prototype).forEach(function(e) {
              a.prototype[e] = r.util.Observer.prototype[e]
            }), this.wavesurfer.Region = a, this.list = {}, this._onReady = function() {
              r.wrapper = r.wavesurfer.drawer.wrapper, r.params.regions && r.params.regions.forEach(function(e) {
                r.add(e)
              }), r.params.dragSelection && r.enableDragSelection(r.params)
            }
          }
          return s(n, null, [{
            key: "create",
            value: function(e) {
              return {
                name: "regions",
                deferInit: !(!e || !e.deferInit) && e.deferInit,
                params: e,
                staticProps: {
                  initRegions: function() {
                    console.warn('Deprecated initRegions! Use wavesurfer.initPlugins("regions") instead!'), this.initPlugin("regions")
                  },
                  addRegion: function(e) {
                    return this.initialisedPluginList.regions || this.initPlugin("regions"), this.regions.add(e)
                  },
                  clearRegions: function() {
                    this.regions && this.regions.clear()
                  },
                  enableDragSelection: function(e) {
                    this.initialisedPluginList.regions || this.initPlugin("regions"), this.regions.enableDragSelection(e)
                  },
                  disableDragSelection: function() {
                    this.regions.disableDragSelection()
                  }
                },
                instance: n
              }
            }
          }]), s(n, [{
            key: "init",
            value: function() {
              this.wavesurfer.isReady && this._onReady(), this.wavesurfer.on("ready", this._onReady)
            }
          }, {
            key: "destroy",
            value: function() {
              this.wavesurfer.un("ready", this._onReady), this.disableDragSelection(), this.clear()
            }
          }, {
            key: "add",
            value: function(e) {
              var t = this,
                r = new this.wavesurfer.Region(e, this.wavesurfer);
              return (this.list[r.id] = r).on("remove", function() {
                delete t.list[r.id]
              }), r
            }
          }, {
            key: "clear",
            value: function() {
              var t = this;
              Object.keys(this.list).forEach(function(e) {
                t.list[e].remove()
              })
            }
          }, {
            key: "enableDragSelection",
            value: function(n) {
              var i, s, a, o, u, l, d, h = this,
                c = n.slop || 2,
                f = this.wavesurfer.drawer.container,
                v = !1 !== n.scroll && this.wavesurfer.params.scrollParent,
                p = n.scrollSpeed || 1,
                m = n.scrollThreshold || 10,
                g = this.wavesurfer.getDuration(),
                w = 0,
                e = function(e) {
                  e.touches && 1 < e.touches.length || (g = h.wavesurfer.getDuration(), u = e.targetTouches ? e.targetTouches[0].identifier : null, s = h.wrapper.scrollWidth - h.wrapper.clientWidth, d = h.wrapper.getBoundingClientRect(), i = !0, a = h.wavesurfer.drawer.handleEvent(e, !0), l = o = null)
                };
              this.wrapper.addEventListener("mousedown", e), this.wrapper.addEventListener("touchstart", e), this.on("disable-drag-selection", function() {
                h.wrapper.removeEventListener("touchstart", e), h.wrapper.removeEventListener("mousedown", e)
              });
              var t = function(e) {
                e.touches && 1 < e.touches.length || (i = !1, w = 0, l = null, o && (h.util.preventClick(), o.fireEvent("update-end", e), h.wavesurfer.fireEvent("region-update-end", o, e)), o = null)
              };
              this.wrapper.addEventListener("mouseup", t), this.wrapper.addEventListener("touchend", t), document.body.addEventListener("mouseup", t), document.body.addEventListener("touchend", t), this.on("disable-drag-selection", function() {
                document.body.removeEventListener("mouseup", t), document.body.removeEventListener("touchend", t), h.wrapper.removeEventListener("touchend", t), h.wrapper.removeEventListener("mouseup", t)
              });
              var r = function(e) {
                if (i && !(++w <= c || e.touches && 1 < e.touches.length || e.targetTouches && e.targetTouches[0].identifier != u)) {
                  o || (o = h.add(n || {}));
                  var t = h.wavesurfer.drawer.handleEvent(e);
                  if (o.update({
                    start: Math.min(t * g, a * g),
                    end: Math.max(t * g, a * g)
                  }), v && f.clientWidth < h.wrapper.scrollWidth) {
                    var r = e.clientX - d.left;
                    (l = r <= m ? -1 : r >= d.right - m ? 1 : null) && function e(t) {
                      if (o && l) {
                        var r = h.wrapper.scrollLeft + p * l;
                        h.wrapper.scrollLeft = r = Math.min(s, Math.max(0, r));
                        var n = h.wavesurfer.drawer.handleEvent(t);
                        o.update({
                          start: Math.min(n * g, a * g),
                          end: Math.max(n * g, a * g)
                        }), r < s && 0 < r && window.requestAnimationFrame(function() {
                          e(t)
                        })
                      }
                    }(e)
                  }
                }
              };
              this.wrapper.addEventListener("mousemove", r), this.wrapper.addEventListener("touchmove", r), this.on("disable-drag-selection", function() {
                h.wrapper.removeEventListener("touchmove", r), h.wrapper.removeEventListener("mousemove", r)
              })
            }
          }, {
            key: "disableDragSelection",
            value: function() {
              this.fireEvent("disable-drag-selection")
            }
          }, {
            key: "getCurrentRegion",
            value: function() {
              var r = this,
                n = this.wavesurfer.getCurrentTime(),
                i = null;
              return Object.keys(this.list).forEach(function(e) {
                var t = r.list[e];
                t.start <= n && t.end >= n && (!i || t.end - t.start < i.end - i.start) && (i = t)
              }), i
            }
          }]), n
        }();
      t.default = o, e.exports = t.default
    }
  })
});
//# sourceMappingURL=wavesurfer.regions.min.js.map
