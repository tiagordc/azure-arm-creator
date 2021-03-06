
var app = new Framework7({
  id: 'com.arc.creator',
  root: '#app',
  theme: "auto",
  name: 'Resource Creator',
  cache: false,
  routes: [
    {
      path: '/admin',
      componentUrl: './static/html/templates.html',
      master: true,
      detailRoutes: [
        {
          path: '/admin/:path/:name/',
          componentUrl: './static/html/template.html'
        }
      ]
    },
    {
      path: '/resources',
      componentUrl: './static/html/resources.html',
      master: true,
      detailRoutes: [
        {
          path: '/resources/:name/',
          componentUrl: './static/html/resource.html'
        }
      ]
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
