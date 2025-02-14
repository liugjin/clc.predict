// Generated by IcedCoffeeScript 108.0.11
if (typeof define !== 'function') { var define = require('amdefine')(module) };
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

define(["underscore", "threejs", "tween"], function(_, THREE, TWEEN) {
  var Room, exports, showingType;
  showingType = ["normal", "wireframe", "capacity"];
  if (!window.debugR) {
    window.debugR = {};
  }
  Room = (function() {
    function Room(scope, element) {
      this.resize = __bind(this.resize, this);
      this.packAction = __bind(this.packAction, this);
      this.unpackAction = __bind(this.unpackAction, this);
      this.setComposer = __bind(this.setComposer, this);
      this.getScreenCoordinate = __bind(this.getScreenCoordinate, this);
      this.selection = __bind(this.selection, this);
      this.meshClick = __bind(this.meshClick, this);
      this.render = __bind(this.render, this);
      this.loadSceneByUrl = __bind(this.loadSceneByUrl, this);
      this.setScene = __bind(this.setScene, this);
      this.init = __bind(this.init, this);
      this.init();
      this.dom = element;
      this.scope = scope;
      this.oldPositionArr = [];
      this.animateList = [];
      this.currentHex = null;
      this.offset = {
        left: 0,
        top: 0,
        width: 0,
        height: 0
      };
      this.meshClick();
    }

    Room.prototype.init = function() {
      this.animate = null;
      this.scene = new THREE.Scene();
      this.scene.autoUpdate = true;
      this.camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 1000);
      this.renderer = new THREE.WebGLRenderer({
        antialias: true,
        alpha: true
      });
      this.renderer.setPixelRatio(window.devicePixelRatio);
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.renderer.shadowMap.enabled = true;
      this.renderer.gammaFactor = 2.2;
      this.renderer.setClearColor(0xEEEEEE, 0.0);
      this.controls = new THREE.OrbitControls(this.camera, this.renderer.domElement);
      this.controls.target.set(0, 0, 0);
      this.controls.enablePan = false;
      this.controls.maxPolarAngle = Math.PI / 2;
      this.raycaster = new THREE.Raycaster();
      this.mouse = new THREE.Vector2();
      return this.clock = new THREE.Clock();
    };

    Room.prototype.setScene = function(options) {
      var height, width;
      width = this.dom.width();
      height = this.dom.height();
      this.camera.position.set(options.x || 0, options.y || 0, options.z || 0);
      this.camera.rotation.set(options.rotationX * Math.PI / 180 || 0, options.rotationY * Math.PI / 180 || 0, options.rotationz * Math.PI / 180 || 0);
      this.camera.fov = options.fov;
      this.camera.aspect = width / height;
      this.renderer.setSize(width, height);
      if (this.dom.children().length === 0) {
        this.dom.append(this.renderer.domElement);
      }
      this.composer = this.setComposer({
        width: width,
        height: height,
        color: ['rgba(0,214,255,0.3)']
      });
      this.offset = {
        width: width,
        height: height,
        left: this.dom.offset().left,
        top: this.dom.offset().top
      };
      if (_.isNull(this.animate)) {
        cancelAnimationFrame(this.animate);
      }
      return this.render();
    };

    Room.prototype.loadSceneByUrl = function(url, callback, preloadCallback) {
      var onErrors, onLoad, onProgress;
      if (!this.objLoader) {
        this.objLoader = new THREE.ObjectLoader();
      }
      onLoad = (function(_this) {
        return function(json) {
          _this.scene.remove(_this.scene.children);
          _this.scene.add(json);
          _this.setScene(json.userData);
          return typeof callback === "function" ? callback(null, json) : void 0;
        };
      })(this);
      onProgress = (function(_this) {
        return function(xhr) {
          return typeof preloadCallback === "function" ? preloadCallback((xhr.loaded / xhr.total * 100).toFixed(0)) : void 0;
        };
      })(this);
      onErrors = function(xhr) {
        return console.error('加载3D文件失败：', xhr);
      };
      return this.objLoader.load(url, onLoad, onProgress, onErrors);
    };

    Room.prototype.render = function() {
      this.animate = requestAnimationFrame(this.render);
      this.composer.render();
      return this.controls.update();
    };

    Room.prototype.meshClick = function() {
      return this.dom.click((function(_this) {
        return function(event) {
          var intersects, offset;
          _this.autoRotate(false, 1);
          offset = _this.offset;
          if (offset.height === 0 || offset.width === 0) {
            return;
          }
          _this.mouse.x = (event.originalEvent.clientX - offset.left) / offset.width * 2 - 1;
          _this.mouse.y = -((event.originalEvent.clientY - offset.top) / offset.height) * 2 + 1;
          _this.raycaster.setFromCamera(_this.mouse, _this.camera);
          intersects = _this.raycaster.intersectObjects(_this.scene.children[0].children, true);
          if (intersects.length > 0 && intersects[0].object.name.indexOf("signal") !== -1) {
            if (intersects[0].object.material.emissive) {
              _this.outlinePass.visibleEdgeColor = intersects[0].object.material.emissive;
              _this.outlinePass.hiddenEdgeColor = intersects[0].object.material.emissive;
            } else if (intersects[0].object.material.color) {
              _this.outlinePass.visibleEdgeColor = intersects[0].object.material.color;
              _this.outlinePass.hiddenEdgeColor = intersects[0].object.material.color;
            }
            _this.outlinePass.selectedObjects = [intersects[0].object];
            _this.scope.label = _this.getScreenCoordinate(_this.outlinePass.selectedObjects[0], {
              width: _this.offset.width,
              height: _this.offset.height,
              top: _this.offset.top,
              left: _this.offset.left
            });
            return _this.scope.$applyAsync();
          } else {
            console.log('不显示');
            _this.outlinePass.selectedObjects = [];
            return _this.scope.label.display = "none";
          }
        };
      })(this));
    };

    Room.prototype.selection = function(data) {
      return this.scene.traverse((function(_this) {
        return function(object3D) {
          if (object3D.name.indexOf("signal-" + data.signalID) !== -1 && object3D.type === 'Mesh') {
            if (object3D.material.emissive) {
              _this.outlinePass.visibleEdgeColor = object3D.material.emissive;
              _this.outlinePass.hiddenEdgeColor = object3D.material.emissive;
            } else if (object3D.material.color) {
              _this.outlinePass.visibleEdgeColor = object3D.material.color;
              _this.outlinePass.hiddenEdgeColor = object3D.material.color;
            }
            _this.outlinePass.selectedObjects = [object3D];
            return _this.scope.label = _this.getScreenCoordinate(_this.outlinePass.selectedObjects[0], {
              width: _this.offset.width,
              height: _this.offset.height,
              top: _this.offset.top,
              left: _this.offset.left
            });
          }
        };
      })(this));
    };

    Room.prototype.getScreenCoordinate = function(mesh, data) {
      var heightHalf, position, vec2, widthHalf;
      position = new THREE.Vector3();
      mesh.localToWorld(position);
      vec2 = position.project(this.camera);
      widthHalf = data.width / 2;
      heightHalf = data.height / 2;
      console.log(mesh.signal);
      return {
        left: Math.round((1 + vec2.x) * widthHalf),
        top: Math.round((1 - vec2.y) * heightHalf),
        display: "block",
        signal: mesh.signal,
        meshName: mesh.name
      };
    };

    Room.prototype.setComposer = function(data) {
      var composer, effectFXAA, renderPass;
      this.renderer.setRenderTarget(new THREE.WebGLRenderTarget(data.width, data.height, {
        minFilter: THREE.LinearFilter,
        magFilter: THREE.LinearFilter,
        format: THREE.RGBAFormat,
        stencilBuffer: false
      }));
      composer = new THREE.EffectComposer(this.renderer);
      renderPass = new THREE.RenderPass(this.scene, this.camera);
      composer.addPass(renderPass);
      this.outlinePass = new THREE.OutlinePass(new THREE.Vector2(data.width, data.height), this.scene, this.camera);
      this.outlinePass.edgeStrength = 10;
      this.outlinePass.edgeGlow = 1;
      this.outlinePass.edgeThickness = 1;
      this.outlinePass.pulsePeriod = 3;
      this.outlinePass.visibleEdgeColor.set(data.color[0]);
      this.outlinePass.hiddenEdgeColor.set(data.color[0]);
      this.outlinePass.selectedObjects = [];
      composer.addPass(this.outlinePass);
      effectFXAA = new THREE.ShaderPass(THREE.FXAAShader);
      effectFXAA.uniforms['resolution'].value.set(1 / data.width, 1 / data.height);
      effectFXAA.renderToScreen = true;
      effectFXAA.clear = true;
      composer.addPass(effectFXAA);
      return composer;
    };

    Room.prototype.autoRotate = function(flag, autoRotateSpeed) {
      var _ref, _ref1, _ref2;
      if ((_ref = this.controls) != null) {
        _ref.autoRotateSpeed = autoRotateSpeed || 2;
      }
      if (flag) {
        if ((_ref1 = this.controls) != null) {
          _ref1.autoRotate = true;
        }
        return this.addAnimate('autoRotate', (function(_this) {
          return function() {
            var _ref2;
            return (_ref2 = _this.controls) != null ? _ref2.update() : void 0;
          };
        })(this));
      } else {
        if ((_ref2 = this.controls) != null) {
          _ref2.autoRotate = false;
        }
        return this.removeAnimate('autoRotate');
      }
    };

    Room.prototype.generatorThings = function(data, open, color) {
      return this.scene.traverse((function(_this) {
        return function(object3D) {
          if (object3D.name.indexOf("signal-" + data.message.signal) !== -1 && object3D.type === 'Mesh') {
            object3D.signal = {
              signalName: data.message.signalName,
              time: data.message.atime,
              signalState: data.message.signalState,
              signalValue: data.message.value,
              advice: data.message.advice
            };
            if (object3D.material.emissive) {
              if (_this.currentHex === null) {
                _this.currentHex = object3D.material.emissive.getHex();
              }
              if (color === null) {
                object3D.material.emissive.set(_this.currentHex);
              } else {
                object3D.material.emissive.set(color);
              }
            } else if (object3D.material.color) {
              if (_this.currentHex === null) {
                _this.currentHex = object3D.material.color.getHex();
              }
              if (color === null) {
                object3D.material.color.set(_this.currentHex);
              } else {
                object3D.material.color.set(color);
              }
            }
            if (open) {
              return _this.selection(data.message);
            }
          }
        };
      })(this));
    };

    Room.prototype.addAnimate = function(key, func) {
      var index, _ref;
      index = _.findLastIndex(this.animateList, {
        key: key
      });
      if (index === -1) {
        return this.animateList.push({
          key: key,
          func: func
        });
      } else {
        return (_ref = this.animateList[index]) != null ? _ref.func = func : void 0;
      }
    };

    Room.prototype.removeAnimate = function(key) {
      var index;
      index = _.findLastIndex(this.animateList, {
        key: key
      });
      if (index === -1) {
        return console.log('err: key is not in list', key, this.animateList);
      }
      return this.animateList.splice(index, 1);
    };

    Room.prototype.unpackAction = function() {
      var animate;
      this.scope.open = true;
      this.scene.traverse((function(_this) {
        return function(value) {
          var originalX, originalY, originalZ, setupX, setupY, setupZ, tween;
          if (value.userData.selectedPositionOffset) {
            originalX = value.position.x;
            originalY = value.position.y;
            originalZ = value.position.z;
            setupX = value.userData.selectedPositionOffset.x;
            setupY = value.userData.selectedPositionOffset.y;
            setupZ = value.userData.selectedPositionOffset.z;
            value.originalPosition = new THREE.Vector3(originalX, originalY, originalZ);
            value.setupPosition = new THREE.Vector3(setupX, setupY, setupZ);
            tween = new TWEEN.Tween(value.position);
            tween.to({
              x: value.setupPosition.x,
              y: value.setupPosition.y,
              z: value.setupPosition.z
            }, 2000).easing(TWEEN.Easing.Elastic.Out);
            return tween.start();
          }
        };
      })(this));
      animate = (function(_this) {
        return function(time) {
          requestAnimationFrame(animate);
          return TWEEN.update(time);
        };
      })(this);
      return requestAnimationFrame(animate);
    };

    Room.prototype.packAction = function() {
      var animate;
      this.scope.open = false;
      this.scene.traverse((function(_this) {
        return function(value) {
          var tween;
          if (value.originalPosition) {
            tween = new TWEEN.Tween(value.position);
            tween.to({
              x: value.originalPosition.x,
              y: value.originalPosition.y,
              z: value.originalPosition.z
            }, 2000).easing(TWEEN.Easing.Exponential.Out);
            return tween.start();
          }
        };
      })(this));
      animate = (function(_this) {
        return function(time) {
          requestAnimationFrame(animate);
          return TWEEN.update(time);
        };
      })(this);
      return requestAnimationFrame(animate);
    };

    Room.prototype.resize = function() {
      var height, width;
      console.log("自适应");
      width = this.dom.width();
      height = this.dom.height();
      if (width !== this.offset.width || height !== this.offset.height) {
        this.camera.aspect = width / height;
        this.camera.updateProjectionMatrix();
        this.renderer.setSize(width, height);
        this.offset = {
          width: width,
          height: height,
          left: this.dom.offset().left,
          top: this.dom.offset().top
        };
        return this.scope.$applyAsync();
      }
    };

    Room.prototype.dispose = function() {};

    return Room;

  })();
  return exports = Room;
});
