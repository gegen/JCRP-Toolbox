(this["webpackJsonppublic-src"]=this["webpackJsonppublic-src"]||[]).push([[0],{17:function(e,t,n){e.exports=n(41)},22:function(e,t,n){},40:function(e,t,n){},41:function(e,t,n){"use strict";n.r(t);var a=n(0),r=n.n(a),o=n(15),l=n.n(o),c=(n(22),n(3)),i=n(2),s=n.n(i),u=n(16);function p(e){for(var t=e.title,n=e.children,o=Object(a.useState)(!1),l=Object(c.a)(o,2),i=l[0],p=l[1],f=Object(a.useState)([]),m=Object(c.a)(f,2),d=m[0],S=m[1],g=Object(a.useState)(0),h=Object(c.a)(g,2),v=h[0],j=h[1],E=t,O=n,y=0;y<d.length;y++){var w;y===d.length-1&&(E=null!==(w=O[d[y]].props.title)&&void 0!==w?w:O[d[y]].props.label),O=O[d[y]].props.children}var N=Object(a.useCallback)((function(e){if(e.data){var t=e.data;switch(t.type){case"display":void 0!==t.toogle?p(t.toogle):console.error("Invalid NUI display toogle");break;case"navigation":if("Up"===t.value)j(0===v?O.length-1:v-1);else if("Down"===t.value)v===O.length-1?j(0):j(v+1);else if("Enter"===t.value){var n=a.Children.toArray(O)[v];n.type===b&&(j(0),S((function(e){return[].concat(Object(u.a)(e),[v])}))),n.props.onSelect&&n.props.onSelect()}else"Back"===t.value&&(0===d.length?s.a.post("http://jcrp-toolbox/close",JSON.stringify()):(j(d[d.length-1]),S(d.filter((function(e,t){return t<d.length-1})))))}}}),[O,v,d,j]);return Object(a.useEffect)((function(){return window.addEventListener("message",N),function(){window.removeEventListener("message",N)}}),[N]),i&&r.a.createElement("div",{className:"Container"},r.a.createElement("div",{className:"title"},E),r.a.createElement("ul",null,a.Children.map(O,(function(e,t){var n=t===v,a=e.props.label;return e.type===b?r.a.createElement("li",{className:n?"selected":""},a," ",r.a.createElement("span",{style:{float:"right",fontWeight:"bold"}},">")):r.a.createElement("li",{className:n?"selected":""},a)}))))}function f(){return null}function b(){return null}n(40);var m=function(){var e=Object(a.useState)(0),t=Object(c.a)(e,2),n=t[0],o=t[1],l=Object(a.useState)("Invalid"),i=Object(c.a)(l,2),u=i[0],m=i[1],d=Object(a.useState)(!1),S=Object(c.a)(d,2),g=S[0],h=S[1],v=Object(a.useCallback)((function(e){if(e.data){var t=e.data;switch(t.type){case"closestPlayer":void 0===t.id||void 0===t.name?h(!1):(o(t.id),m(t.name),h(!0))}}}),[]);function j(e){s.a.post("http://jcrp-toolbox/setSpikes",JSON.stringify(e))}function E(e){s.a.post("http://jcrp-toolbox/spawnObject",JSON.stringify(e))}return Object(a.useEffect)((function(){return window.addEventListener("message",v),function(){window.removeEventListener("message",v)}}),[v]),r.a.createElement(p,{title:"JCRP Toolbox"},r.a.createElement(b,{label:"Actions",title:g?"[".concat(n,"] ").concat(u):"No player nearby."},r.a.createElement(f,{label:"Cuff / Uncuff",onSelect:function(){if(!g)return s.a.post("http://jcrp-toolbox/displayMsg",JSON.stringify("No player nearby."));s.a.post("http://jcrp-toolbox/executeCommand",JSON.stringify("cuff "+n))}}),r.a.createElement(f,{label:"Drag",onSelect:function(){if(!g)return s.a.post("http://jcrp-toolbox/displayMsg",JSON.stringify("No player nearby."));s.a.post("http://jcrp-toolbox/executeCommand",JSON.stringify("drag "+n))}})),r.a.createElement(b,{label:"Spikes"},r.a.createElement(f,{label:"Place Spikes",onSelect:function(){return j(!1)}}),r.a.createElement(f,{label:"Place 2x Spikes",onSelect:function(){return j(!0)}}),r.a.createElement(f,{label:"Remove Spikes",onSelect:function(){s.a.post("http://jcrp-toolbox/removeSpikes",JSON.stringify())}})),r.a.createElement(b,{label:"Objects",title:"Object Spawner"},r.a.createElement(f,{label:"Police Barrier",onSelect:function(){return E("policeBarrier")}}),r.a.createElement(f,{label:"Road Barrier",onSelect:function(){return E("roadBarrier")}}),r.a.createElement(f,{label:"Road Barrier Arrow",onSelect:function(){return E("roadBarrierArrow")}}),r.a.createElement(f,{label:"Traffic Cone",onSelect:function(){return E("cone")}}),r.a.createElement(f,{label:"Traffic Barrel",onSelect:function(){return E("trafficBarrel")}}),r.a.createElement(f,{label:"Remove Close Objects",onSelect:function(){s.a.post("http://jcrp-toolbox/deleteCloseObjects",JSON.stringify())}})),r.a.createElement(f,{label:"Hands up",onSelect:function(){s.a.post("http://jcrp-toolbox/executeCommand",JSON.stringify("e handsup"))}}))};Boolean("localhost"===window.location.hostname||"[::1]"===window.location.hostname||window.location.hostname.match(/^127(?:\.(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$/));l.a.render(r.a.createElement(r.a.StrictMode,null,r.a.createElement(m,null)),document.getElementById("root")),"serviceWorker"in navigator&&navigator.serviceWorker.ready.then((function(e){e.unregister()})).catch((function(e){console.error(e.message)}))}},[[17,1,2]]]);
//# sourceMappingURL=main.497d1410.chunk.js.map