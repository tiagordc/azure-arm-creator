
var app = new Framework7({
  id: 'com.arc.machines',
  root: '#app',
  theme: "auto",
  name: 'Virtual Machines',
  cache: false,
  routes: [
    {
      path: '/:name/admin',
      componentUrl: '../static/html/resource.html'
    }
  ]
});

var $$ = Dom7;

var mainView = app.views.create('.view-main', {
  // stackPages: true,
  on: {
    pageInit: function (data) {

    }
  }
});